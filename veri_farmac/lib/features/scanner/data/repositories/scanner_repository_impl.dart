import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/open_food_facts_datasource.dart';
import '../models/scan_result_model.dart';
import '../../../medicine_detail/data/datasources/invima_api_datasource.dart';
import '../../../medicine_detail/data/models/medicine_model.dart';
import '../../../medicine_detail/domain/entities/medicine.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  const ScannerRepositoryImpl({
    required this.invima,
    required this.ocr,
    required this.claude,
    required this.openFoodFacts,
  });
  final InvimaApiDataSource       invima;
  final OcrDataSource             ocr;
  final ClaudeAiDataSource        claude;
  final OpenFoodFactsDatasource   openFoodFacts;

  @override
  Future<ScanResult> processBarcode(String barcode) async {
    if (_isEanBarcode(barcode)) {
      // Paso 1: buscar el nombre del producto en Open Food Facts
      final productName = await openFoodFacts.getProductName(barcode);

      if (productName != null) {
        // Paso 2: usar ese nombre para buscar en INVIMA
        debugPrint('[Scanner] OFF encontró: $productName — buscando en INVIMA...');
        final medicine = await invima.findByName(productName);
        if (medicine != null) {
          return _buildResult(
            scannedValue: barcode,
            method:       ScanMethod.barcode,
            medicine:     medicine,
            confidence:   0.75,
          );
        }
        // OFF encontró nombre pero INVIMA no lo tiene
        return ScanResultModel(
          id:           const Uuid().v4(),
          scannedValue: barcode,
          method:       ScanMethod.barcode,
          scannedAt:    DateTime.now(),
          confidence:   0.0,
          error:        'Producto identificado como "$productName" pero no se '
                        'encontró en INVIMA.\n'
                        'Usa el modo OCR y apunta al número de registro '
                        '(ej. "INVIMA 2008M-XXXXXXX") del empaque.',
        );
      }

      // Paso 3: EAN no está en Open Food Facts
      return ScanResultModel(
        id:           const Uuid().v4(),
        scannedValue: barcode,
        method:       ScanMethod.barcode,
        scannedAt:    DateTime.now(),
        confidence:   0.0,
        error:        'Código de barras no encontrado en ninguna base de datos.\n'
                      'Cambia al modo OCR y apunta al número de registro '
                      '(ej. "INVIMA 2008M-XXXXXXX") impreso en el empaque.',
      );
    }

    // Barcode no-EAN — podría ser un código de registro impreso como barcode
    final medicine = await invima.findByRegistry(barcode);
    return _buildResult(
      scannedValue: barcode,
      method:       ScanMethod.barcode,
      medicine:     medicine,
      confidence:   medicine != null ? 0.80 : 0.0,
    );
  }

  @override
  Future<ScanResult> processOcr(String text) async {
    // Si el texto contiene un código INVIMA, busca por registro.
    // Si no, busca por nombre (palabras del empaque).
    final invimaCode = _extractInvimaCode(text);
    MedicineModel? medicine;

    if (invimaCode != null) {
      medicine = await invima.findByRegistry(invimaCode);
    } else {
      final results = await invima.search(text);
      medicine = results.isNotEmpty ? results.first as MedicineModel? : null;
    }

    // Detectar fecha de vencimiento física en el texto OCR.
    // La API de INVIMA solo registra la autorización sanitaria, no la fecha
    // de vencimiento por lote. Si el empaque tiene una fecha vencida, se
    // sobrescribe el estado a 'vencido' para que el historial lo registre
    // correctamente aunque el registro INVIMA esté vigente.
    final expDate   = _extractExpirationDate(text);
    final isExpired = expDate != null &&
        DateTime(expDate.year, expDate.month + 1).isBefore(DateTime.now());

    if (isExpired && medicine != null) {
      return ScanResultModel(
        id:             const Uuid().v4(),
        scannedValue:   text,
        method:         ScanMethod.ocr,
        scannedAt:      DateTime.now(),
        confidence:     0.85,
        medicineName:   medicine.name,
        sanitaryRecord: medicine.sanitaryRecord,
        status:         'vencido',
      );
    }

    return _buildResult(
      scannedValue: text,
      method:       ScanMethod.ocr,
      medicine:     medicine,
      confidence:   medicine != null ? 0.85 : 0.0,
    );
  }

  @override
  Future<ScanResult> analyzeImage(String imagePath) async {
    final analysis    = await claude.analyzePackaging(imagePath);
    final isAuthentic = analysis['isAuthentic'] as bool? ?? false;
    final confidence  = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final observation = analysis['observations'] as String? ?? '';
    return ScanResultModel(
      id:           const Uuid().v4(),
      scannedValue: imagePath,
      method:       ScanMethod.visual,
      scannedAt:    DateTime.now(),
      confidence:   confidence,
      status:       isAuthentic ? 'vigente' : 'sospechoso',
      error:        isAuthentic ? null : observation,
    );
  }

  // Construye el ScanResultModel a partir de un Medicine de la API
  ScanResultModel _buildResult({
    required String        scannedValue,
    required ScanMethod    method,
    required Medicine?     medicine,
    required double        confidence,
  }) {
    return ScanResultModel(
      id:             const Uuid().v4(),
      scannedValue:   scannedValue,
      method:         method,
      scannedAt:      DateTime.now(),
      confidence:     confidence,
      medicineName:   medicine?.name,
      sanitaryRecord: medicine?.sanitaryRecord,
      status:         medicine?.condition.name,
      error:          medicine == null ? 'No information found in INVIMA' : null,
    );
  }

  // Extrae un código INVIMA del texto OCR del empaque
  String? _extractInvimaCode(String text) {
    final regex = RegExp(r'INVIMA\s*\d{4}[A-Z]-?\d{6,7}', caseSensitive: false);
    return regex.firstMatch(text)?.group(0);
  }

  // EAN/UPC barcodes are purely numeric (8–14 digits)
  bool _isEanBarcode(String value) =>
      RegExp(r'^\d{8,14}$').hasMatch(value.trim());

  // Extrae la fecha de vencimiento del texto OCR del empaque.
  // Soporta: "Vence: 11/2025", "VENCE: 11 /2025", "Vencimiento\n11/2025", "Exp.: 11-2025"
  DateTime? _extractExpirationDate(String text) {
    final regex = RegExp(
      r'(?:vence|vencimiento|fecha\s*de\s*venc\w*|exp(?:ira\w*)?\.?)'
      r'\s*:?\s*'
      r'(\d{1,2})\s*[\/\-]\s*(\d{4})',  // permite espacios antes/después del separador
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match == null) return null;
    final month = int.tryParse(match.group(1)!);
    final year  = int.tryParse(match.group(2)!);
    if (month == null || year == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }
}
