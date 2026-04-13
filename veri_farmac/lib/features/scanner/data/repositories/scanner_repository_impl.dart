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
    // El código de barras EAN no existe en la API del INVIMA.
    // Se intenta buscar por nombre como mejor esfuerzo.
    // El usuario podrá ver el resultado en la pantalla de detalle.
    final medicine = await invima.findByName(barcode);
    return _buildResult(
      scannedValue: barcode,
      method:       ScanMethod.barcode,
      medicine:     medicine,
      confidence:   medicine != null ? 0.70 : 0.0,
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
}
