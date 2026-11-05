import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/open_food_facts_datasource.dart';
import '../datasources/open_products_facts_datasource.dart';
import '../datasources/upc_lookup_datasource.dart';
import '../models/scan_result_model.dart';
import '../utils/health_product_classifier.dart';
import '../../domain/utils/scan_text_parser.dart';
import '../../../medicine_detail/data/datasources/invima_api_datasource.dart';
import '../../../medicine_detail/data/models/medicine_model.dart';
import '../../../medicine_detail/domain/entities/medicine.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  const ScannerRepositoryImpl({
    required this.invima,
    required this.ocr,
    required this.claude,
    required this.openFoodFacts,
    required this.openProductsFacts,
    required this.upcLookup,
  });
  final InvimaApiDataSource         invima;
  final OcrDataSource               ocr;
  final ClaudeAiDataSource          claude;
  final OpenFoodFactsDatasource     openFoodFacts;
  final OpenProductsFactsDatasource openProductsFacts;
  final UpcLookupDataSource         upcLookup;

  @override
  Future<ScanResult> processBarcode(String barcode) async {
    if (ScanTextParser.isEanBarcode(barcode)) {
      // Paso 1: buscar el producto en tres bases gratuitas, en orden —
      // Open Food Facts (alimentos), Open Products Facts (el resto del
      // catálogo, misma organización) y UPCItemDB (retail general) como
      // último respaldo. Ninguna es específica de medicamentos: no existe
      // una base pública gratuita que cruce código de barras ↔ INVIMA.
      final info = await openFoodFacts.getProductInfo(barcode)
          ?? await openProductsFacts.getProductInfo(barcode)
          ?? await upcLookup.getProductInfo(barcode);

      if (info != null) {
        // El producto existe en una base genérica pero no parece de salud
        // (ej. tecnología, aseo, alimentos sin más): se le avisa al usuario
        // en vez de intentar — y fallar — una búsqueda sin sentido en INVIMA.
        if (!HealthProductClassifier.looksLikeHealthProduct(info)) {
          return ScanResultModel(
            id:           const Uuid().v4(),
            scannedValue: barcode,
            method:       ScanMethod.barcode,
            scannedAt:    DateTime.now(),
            confidence:   0.0,
            medicineName: info.name,
            error:        'Este código corresponde a "${info.name}"'
                          '${info.category != null ? ' (${info.category})' : ''}, '
                          'que no parece ser un medicamento ni un producto natural.\n'
                          'VeriFarmac solo verifica medicamentos y productos '
                          'naturales — este producto está fuera de su alcance.',
          );
        }

        // Paso 2: usar el nombre para buscar en INVIMA
        debugPrint('[Scanner] Producto encontrado: ${info.name} — buscando en INVIMA...');
        final medicine = await invima.findByName(info.name);
        if (medicine != null) {
          return _buildResult(
            scannedValue: barcode,
            method:       ScanMethod.barcode,
            medicine:     medicine,
            confidence:   0.75,
          );
        }
        // Se identificó como producto de salud pero INVIMA no lo tiene
        return ScanResultModel(
          id:           const Uuid().v4(),
          scannedValue: barcode,
          method:       ScanMethod.barcode,
          scannedAt:    DateTime.now(),
          confidence:   0.0,
          error:        'Producto identificado como "${info.name}" pero no se '
                        'encontró en INVIMA.\n'
                        'Usa el modo OCR y apunta al número de registro '
                        '(ej. "INVIMA 2008M-XXXXXXX") del empaque.',
        );
      }

      // Paso 3: EAN no está en ninguna base de datos de productos
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
    final invimaCode = ScanTextParser.extractInvimaCode(text);
    final expiryDate = ScanTextParser.extractExpiryDate(text);
    final expired    = ScanTextParser.isExpired(expiryDate);
    MedicineModel? medicine;

    if (invimaCode != null) {
      medicine = await invima.findByRegistry(invimaCode);
    } else {
      final results = await invima.search(text);
      medicine = results.isNotEmpty ? results.first as MedicineModel? : null;
    }

    // La fecha física impresa en el empaque tiene prioridad sobre el estado INVIMA
    if (expired) {
      return ScanResultModel(
        id:             const Uuid().v4(),
        scannedValue:   text,
        method:         ScanMethod.ocr,
        scannedAt:      DateTime.now(),
        confidence:     medicine != null ? 0.90 : 0.70,
        medicineName:   medicine?.name,
        sanitaryRecord: medicine?.sanitaryRecord,
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
    final analysis     = await claude.analyzePackaging(imagePath);
    final isAuthentic  = analysis['isAuthentic'] as bool? ?? false;
    final confidence   = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final observation  = analysis['observations'] as String? ?? '';
    final expiryDate   = ScanTextParser.parseExpiryString(analysis['expiryDate'] as String?);
    final expired      = ScanTextParser.isExpired(expiryDate);
    final registryText = analysis['registrySanitario'] as String?;

    // La IA no decide vigencia por sí sola: si logró leer un registro
    // sanitario en el empaque, se contrasta contra INVIMA igual que en OCR.
    MedicineModel? medicine;
    final code = registryText != null ? ScanTextParser.extractInvimaCode(registryText) : null;
    if (code != null) {
      medicine = await invima.findByRegistry(code);
    }

    final String status;
    if (expired) {
      status = 'vencido';
    } else if (medicine != null) {
      status = medicine.condition.name;
    } else {
      status = isAuthentic ? 'vigente' : 'sospechoso';
    }

    return ScanResultModel(
      id:             const Uuid().v4(),
      scannedValue:   imagePath,
      method:         ScanMethod.visual,
      scannedAt:      DateTime.now(),
      confidence:     medicine != null ? 0.85 : confidence,
      medicineName:   medicine?.name,
      sanitaryRecord: medicine?.sanitaryRecord,
      status:         status,
      error:          observation.isNotEmpty ? observation : null,
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
}
