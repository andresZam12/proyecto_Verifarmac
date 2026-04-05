import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/invima_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../models/scan_result_model.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  const ScannerRepositoryImpl({required this.invima, required this.ocr, required this.claude});
  final InvimaDataSource   invima;
  final OcrDataSource      ocr;
  final ClaudeAiDataSource claude;

  @override
  Future<ScanResult> processBarcode(String barcode) async {
    final data = await invima.findByBarcode(barcode);
    return ScanResultModel(
      id: const Uuid().v4(), scannedValue: barcode,
      method: ScanMethod.barcode, scannedAt: DateTime.now(),
      confidence:     data != null ? 0.95 : 0.0,
      medicineName:   data?['nombre'] as String?,
      sanitaryRecord: data?['registro'] as String?,
      status:         data?['estado'] as String?,
      error:          data == null ? 'Medicine not found' : null,
    );
  }

  @override
  Future<ScanResult> processOcr(String text) async {
    final invimaCode = _extractInvimaCode(text);
    Map<String, dynamic>? data;
    if (invimaCode != null) {
      data = await invima.findByRegistry(invimaCode);
    } else {
      final results = await invima.search(text);
      data = results.isNotEmpty ? results.first : null;
    }
    return ScanResultModel(
      id: const Uuid().v4(), scannedValue: text,
      method: ScanMethod.ocr, scannedAt: DateTime.now(),
      confidence:     data != null ? 0.80 : 0.0,
      medicineName:   data?['nombre'] as String?,
      sanitaryRecord: data?['registro'] as String?,
      status:         data?['estado'] as String?,
      error:          data == null ? 'No information found' : null,
    );
  }

  @override
  Future<ScanResult> analyzeImage(String imagePath) async {
    final analysis    = await claude.analyzePackaging(imagePath);
    final isAuthentic = analysis['isAuthentic'] as bool? ?? false;
    final confidence  = (analysis['confidence'] as num?)?.toDouble() ?? 0.0;
    final observation = analysis['observations'] as String? ?? '';
    return ScanResultModel(
      id: const Uuid().v4(), scannedValue: imagePath,
      method: ScanMethod.visual, scannedAt: DateTime.now(),
      confidence: confidence,
      status: isAuthentic ? 'vigente' : 'sospechoso',
      error:  isAuthentic ? null : observation,
    );
  }

  String? _extractInvimaCode(String text) {
    final regex = RegExp(r'INVIMA\s*\d{4}[A-Z]-?\d{6,7}', caseSensitive: false);
    return regex.firstMatch(text)?.group(0);
  }
}
