// Datasource de código de barras con mobile_scanner.

import 'package:mobile_scanner/mobile_scanner.dart';

// Lee códigos de barras usando la cámara del dispositivo.
// Wrappea la librería mobile_scanner.
class BarcodeDataSource {
  final MobileScannerController controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  // Enciende o apaga la linterna
  Future<void> toggleLinterna() async {
    await controlador.toggleTorch();
  }

  // Libera los recursos de la cámara al salir de la pantalla
  void dispose() {
    controlador.dispose();
  }
}