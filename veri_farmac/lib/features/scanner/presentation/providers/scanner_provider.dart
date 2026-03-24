// Estado del scanner con Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/claude_ai_datasource.dart';
import '../../data/datasources/invima_datasource.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/analyze_image_usecase.dart';
import '../../domain/usecases/scan_by_barcode_usecase.dart';
import '../../domain/usecases/scan_by_ocr_usecase.dart';
import '../../../../../core/network/dio_client.dart';

// Estados posibles del scanner
enum EstadoScanner { inactivo, escaneando, analizando, exitoso, error }

class ScannerState {
  const ScannerState({
    this.estado = EstadoScanner.inactivo,
    this.resultado,
    this.error,
  });

  final EstadoScanner estado;
  final ScanResult?   resultado;
  final String?       error;
}

// Notifier que maneja el flujo completo del escaneo
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._porBarcode, this._porOcr, this._porImagen)
      : super(const ScannerState());

  final ScanByBarcodeUseCase _porBarcode;
  final ScanByOcrUseCase     _porOcr;
  final AnalyzeImageUseCase  _porImagen;

  // Procesa un código de barras detectado por la cámara
  Future<void> escanearBarcode(String barcode) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      final resultado = await _porBarcode(barcode);
      state = ScannerState(
        estado:    EstadoScanner.exitoso,
        resultado: resultado,
      );
    } catch (e) {
      state = ScannerState(
        estado: EstadoScanner.error,
        error:  'Error al procesar el código',
      );
    }
  }

  // Procesa texto capturado con OCR
  Future<void> escanearOcr(String texto) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      final resultado = await _porOcr(texto);
      state = ScannerState(
        estado:    EstadoScanner.exitoso,
        resultado: resultado,
      );
    } catch (e) {
      state = ScannerState(
        estado: EstadoScanner.error,
        error:  'Error al procesar el texto',
      );
    }
  }

  // Analiza una imagen del empaque con Claude API
  Future<void> analizarImagen(String rutaImagen) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      final resultado = await _porImagen(rutaImagen);
      state = ScannerState(
        estado:    EstadoScanner.exitoso,
        resultado: resultado,
      );
    } catch (e) {
      state = ScannerState(
        estado: EstadoScanner.error,
        error:  'Error al analizar la imagen',
      );
    }
  }

  // Resetea el scanner para un nuevo escaneo
  void reiniciar() {
    state = const ScannerState();
  }
}

// Providers
final _dioProvider = Provider((ref) => DioClient().dio);

final _repositoryProvider = Provider((ref) => ScannerRepositoryImpl(
      invima: InvimaDataSource(),
      ocr:    OcrDataSource(),
      claude: ClaudeAiDataSource(ref.read(_dioProvider)),
    ));

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return ScannerNotifier(
    ScanByBarcodeUseCase(repo),
    ScanByOcrUseCase(repo),
    AnalyzeImageUseCase(repo),
  );
});
