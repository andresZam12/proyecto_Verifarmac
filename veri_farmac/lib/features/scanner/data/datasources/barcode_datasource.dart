import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeDataSource {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  Future<void> toggleTorch() async => await controller.toggleTorch();
  void dispose() => controller.dispose();
}
