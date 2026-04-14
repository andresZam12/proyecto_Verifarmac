import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../models/scan_result_model.dart';
import '../../../medicine_detail/data/datasources/invima_api_datasource.dart';
import '../../../medicine_detail/data/models/medicine_model.dart';
import '../../../medicine_detail/domain/entities/medicine.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  const ScannerRepositoryImpl({
    required this.invima,
    required this.ocr,
    required this.claude,
  });
  final InvimaApiDataSource invima;
  final OcrDataSource       ocr;
  final ClaudeAiDataSource  claude;

  @override
  Future<ScanResult> processBarcode(String barcode) async {
    // EAN/UPC barcodes (all digits, 8-14 chars) are NOT in the INVIMA dataset.
    // The INVIMA public API only has registry numbers (expediente), product names,
    // active ingredients, etc. — no EAN field.
    if (_isEanBarcode(barcode)) {
      return ScanResultModel(
        id:           const Uuid().v4(),
        scannedValue: barcode,
        method:       ScanMethod.barcode,
        scannedAt:    DateTime.now(),
        confidence:   0.0,
        error:        'Código de barras EAN no registrado en INVIMA.\n'
                      'Usa el modo OCR y apunta al número de registro '
                      '(ej. "INVIMA 2008M-XXXXXXX") impreso en el empaque.',
      );
    }

    // Non-EAN barcode — could be a registry number printed as barcode.
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
}
