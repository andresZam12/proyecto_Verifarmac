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
  Future<ScanResult> procesarBarcode(String barcode) async {
    final datos = await invima.buscarPorBarcode(barcode);
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: barcode,
      metodo: MetodoEscaneo.barcode, escaneadoEn: DateTime.now(),
      confianza: datos != null ? 0.95 : 0.0,
      nombreMedicamento: datos?['nombre'] as String?,
      registroSanitario: datos?['registro'] as String?,
      estado: datos?['estado'] as String?,
      error: datos == null ? 'Medicamento no encontrado' : null,
    );
  }

  @override
  Future<ScanResult> procesarOcr(String texto) async {
    final codigoInvima = _extraerCodigoInvima(texto);
    Map<String, dynamic>? datos;
    if (codigoInvima != null) {
      datos = await invima.buscarPorRegistro(codigoInvima);
    } else {
      final resultados = await invima.buscarPorTexto(texto);
      datos = resultados.isNotEmpty ? resultados.first : null;
    }
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: texto,
      metodo: MetodoEscaneo.ocr, escaneadoEn: DateTime.now(),
      confianza: datos != null ? 0.80 : 0.0,
      nombreMedicamento: datos?['nombre'] as String?,
      registroSanitario: datos?['registro'] as String?,
      estado: datos?['estado'] as String?,
      error: datos == null ? 'No se encontró información' : null,
    );
  }

  @override
  Future<ScanResult> analizarImagen(String rutaImagen) async {
    final analisis    = await claude.analizarEmpaque(rutaImagen);
    final esAutentico = analisis['esAudentico'] as bool? ?? false;
    final confianza   = (analisis['confianza'] as num?)?.toDouble() ?? 0.0;
    final observacion = analisis['observaciones'] as String? ?? '';
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: rutaImagen,
      metodo: MetodoEscaneo.visual, escaneadoEn: DateTime.now(),
      confianza: confianza,
      estado: esAutentico ? 'vigente' : 'sospechoso',
      error: esAutentico ? null : observacion,
    );
  }

  String? _extraerCodigoInvima(String texto) {
    final regex = RegExp(r'INVIMA\s*\d{4}[A-Z]-?\d{6,7}', caseSensitive: false);
    return regex.firstMatch(texto)?.group(0);
  }
}
