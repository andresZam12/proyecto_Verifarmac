import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/claude_ai_datasource.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../../medicine_detail/data/datasources/invima_api_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/analyze_image_usecase.dart';
import '../../domain/usecases/scan_by_barcode_usecase.dart';
import '../../domain/usecases/scan_by_ocr_usecase.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../../core/constants/app_strings.dart';

enum ScannerStatus { idle, scanning, analyzing, success, error }

class ScannerState {
  const ScannerState({
    this.status = ScannerStatus.idle,
    this.result,
    this.error,
  });
  final ScannerStatus status;
  final ScanResult?   result;
  final String?       error;
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._byBarcode, this._byOcr, this._byImage)
      : super(const ScannerState());

  final ScanByBarcodeUseCase _byBarcode;
  final ScanByOcrUseCase     _byOcr;
  final AnalyzeImageUseCase  _byImage;

  Future<void> scanBarcode(String barcode) async {
    state = const ScannerState(status: ScannerStatus.analyzing);
    try {
      final result = await _byBarcode(barcode);
      // Si el resultado trae un error (ej: código EAN no indexado), mostrar en pantalla
      // sin navegar a la pantalla de detalle.
      state = result.error != null
          ? ScannerState(status: ScannerStatus.error, error: result.error)
          : ScannerState(status: ScannerStatus.success, result: result);
    } catch (_) {
      state = const ScannerState(
        status: ScannerStatus.error,
        error: AppStrings.errorProcessBarcode,
      );
    }
  }

  Future<void> scanOcr(String text) async {
    state = const ScannerState(status: ScannerStatus.analyzing);
    try {
      final result = await _byOcr(text);
      state = result.error != null
          ? ScannerState(status: ScannerStatus.error, error: result.error)
          : ScannerState(status: ScannerStatus.success, result: result);
    } catch (_) {
      state = const ScannerState(
        status: ScannerStatus.error,
        error: AppStrings.errorProcessText,
      );
    }
  }

  Future<void> analyzeImage(String imagePath) async {
    state = const ScannerState(status: ScannerStatus.analyzing);
    try {
      state = ScannerState(
        status: ScannerStatus.success,
        result: await _byImage(imagePath),
      );
    } catch (_) {
      state = const ScannerState(
        status: ScannerStatus.error,
        error: AppStrings.errorAnalyzeImage,
      );
    }
  }

  void reset() => state = const ScannerState();
}

final _dioProvider        = Provider((ref) => DioClient().dio);
final _repositoryProvider = Provider(
  (ref) => ScannerRepositoryImpl(
    invima: InvimaApiDataSource(),
    ocr:    OcrDataSource(),
    claude: ClaudeAiDataSource(ref.read(_dioProvider)),
  ),
);

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return ScannerNotifier(
    ScanByBarcodeUseCase(repo),
    ScanByOcrUseCase(repo),
    AnalyzeImageUseCase(repo),
  );
});
