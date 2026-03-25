import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeDataSource {
  final MobileScannerController controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  Future<void> toggleLinterna() async => await controlador.toggleTorch();
  void dispose() => controlador.dispose();
}
