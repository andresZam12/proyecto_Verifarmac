import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/open_food_facts_datasource.dart';
import '../datasources/upc_lookup_datasource.dart';
import '../models/barcode_product_info.dart';
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
    required this.upcLookup,
  });
  final InvimaApiDataSource       invima;
  final OcrDataSource             ocr;
  final ClaudeAiDataSource        claude;
  final OpenFoodFactsDatasource   openFoodFacts;
  final UpcLookupDataSource       upcLookup;

  // Palabras que sugieren que un producto es un medicamento o producto
  // natural con fines terapéuticos — lo único que VeriFarmac puede
  // verificar contra INVIMA. Heurística de mejor esfuerzo: las bases de
  // código de barras genéricas (Open Food Facts, UPCItemDB) no tienen una
  // categoría "medicamento" estandarizada, así que se busca por palabras
  // clave en el nombre y la categoría que sí reportan.
  static const _healthKeywords = [
    'medic', 'farmac', 'drug', 'pill', 'tablet', 'tableta', 'capsul',
    'jarabe', 'syrup', 'suplement', 'supplement', 'vitamin', 'vitamina',
    'salud', 'health', 'natural', 'herbal', 'fitoterap', 'analges',
    'antibiot', 'antiinflamat', 'dolor', 'pain relief', 'pharma',
  ];

  bool _looksLikeHealthProduct(BarcodeProductInfo info) {
    final text = '${info.name} ${info.category ?? ''}'.toLowerCase();
    return _healthKeywords.any(text.contains);
  }

  @override
  Future<ScanResult> processBarcode(String barcode) async {
    if (_isEanBarcode(barcode)) {
      // Paso 1: buscar el producto — primero en Open Food Facts (sobre todo
      // alimentos) y, si no aparece, en UPCItemDB como respaldo (cobertura
      // general de consumo, tampoco específica de medicamentos: no existe
      // una base pública gratuita que cruce código de barras ↔ INVIMA).
      final info = await openFoodFacts.getProductInfo(barcode)
          ?? await upcLookup.getProductInfo(barcode);

      if (info != null) {
        // El producto existe en una base genérica pero no parece de salud
        // (ej. tecnología, aseo, alimentos sin más): se le avisa al usuario
        // en vez de intentar — y fallar — una búsqueda sin sentido en INVIMA.
        if (!_looksLikeHealthProduct(info)) {
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
    final invimaCode = _extractInvimaCode(text);
    final expiryDate = _extractExpiryDate(text);
    final expired    = _isExpired(expiryDate);
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
    final expiryDate   = _parseExpiryString(analysis['expiryDate'] as String?);
    final expired      = _isExpired(expiryDate);
    final registryText = analysis['registrySanitario'] as String?;

    // La IA no decide vigencia por sí sola: si logró leer un registro
    // sanitario en el empaque, se contrasta contra INVIMA igual que en OCR.
    MedicineModel? medicine;
    final code = registryText != null ? _extractInvimaCode(registryText) : null;
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

  // Extrae un código INVIMA del texto OCR del empaque.
  // Acepta espacios alrededor del guion: "2008M- 007952" o "2008M-007952".
  String? _extractInvimaCode(String text) {
    final regex = RegExp(
      r'INVIMA\s*\d{4}[A-Z]\s*-?\s*\d{6,7}',
      caseSensitive: false,
    );
    return regex.firstMatch(text)?.group(0);
  }

  // EAN/UPC barcodes are purely numeric (8–14 digits)
  bool _isEanBarcode(String value) =>
      RegExp(r'^\d{8,14}$').hasMatch(value.trim());

  // Extrae la fecha de vencimiento del texto OCR del empaque.
  // Acepta formatos: MM/YYYY, MM/YY y espacios alrededor del separador.
  // Ej: "VENCE: 07/2020", "EXP. 07 / 2020", "F.V.: 07/20"
  static final _expiryPattern = RegExp(
    r'(?:vence|vencimiento|f\.?\s*venc\.?|fv|exp(?:iry|ires)?)'
    r'\s*[:\.]?\s*'
    r'(\d{1,2})\s*[/\-\.]\s*(\d{2,4})',
    caseSensitive: false,
  );

  DateTime? _extractExpiryDate(String text) {
    final match = _expiryPattern.firstMatch(text);
    if (match == null) return null;
    return _parseMonthYear(match.group(1)!, match.group(2)!);
  }

  DateTime? _parseExpiryString(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    final parts = raw.trim().split(RegExp(r'\s*[/\-\.]\s*'));
    if (parts.length < 2) return null;
    return _parseMonthYear(parts[0], parts[1]);
  }

  DateTime? _parseMonthYear(String monthStr, String yearStr) {
    try {
      final month = int.parse(monthStr.trim());
      var   year  = int.parse(yearStr.trim());
      if (year < 100) year += 2000;
      if (month < 1 || month > 12) return null;
      // Vence el último día de ese mes
      return DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    } catch (_) {
      return null;
    }
  }

  bool _isExpired(DateTime? date) =>
      date != null && date.isBefore(DateTime.now());
}
