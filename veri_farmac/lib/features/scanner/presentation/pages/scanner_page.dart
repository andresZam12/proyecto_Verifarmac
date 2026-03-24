// Pantalla del scanner con cámara y overlay.
// TODO: integrar mobile_scanner, overlay de escaneo y modo barcode/OCR

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_mode_toggle.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  // Controlador de la cámara
  final _controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  ModoEscaneo _modo = ModoEscaneo.barcode;
  bool _lintErnaEncendida = false;
  bool _yaProceso = false; // evita procesar el mismo código dos veces

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);

    // Navega al resultado cuando el escaneo es exitoso
    ref.listen(scannerProvider, (anterior, actual) {
      if (actual.estado == EstadoScanner.exitoso && actual.resultado != null) {
        context.push(AppRoutes.medicamento, extra: actual.resultado);
        ref.read(scannerProvider.notifier).reiniciar();
        _yaProceso = false;
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Escanear'),
        actions: [
          // Botón de linterna
          IconButton(
            onPressed: _toggleLinterna,
            icon: Icon(
              _lintErnaEncendida
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Cámara
          MobileScanner(
            controller: _controlador,
            onDetect: _alDetectar,
          ),

          // Overlay con el marco de escaneo
          ScannerOverlay(
            mensaje: _modo == ModoEscaneo.barcode
                ? 'Apunta al código de barras'
                : 'Apunta al texto del empaque',
          ),

          // Toggle de modo en la parte superior
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ScanModeToggle(
                modoActual: _modo,
                alCambiar: (modo) => setState(() => _modo = modo),
              ),
            ),
          ),

          // Indicador de carga mientras analiza
          if (scannerState.estado == EstadoScanner.analizando)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const AppLoading(mensaje: 'Analizando medicamento...'),
            ),

          // Mensaje de error
          if (scannerState.estado == EstadoScanner.error)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  scannerState.error ?? 'Error al escanear',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Se llama cuando la cámara detecta algo
  void _alDetectar(BarcodeCapture captura) {
    if (_yaProceso) return;

    final barcode = captura.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    _yaProceso = true;

    if (_modo == ModoEscaneo.barcode) {
      ref.read(scannerProvider.notifier).escanearBarcode(barcode);
    } else {
      ref.read(scannerProvider.notifier).escanearOcr(barcode);
    }
  }

  // Enciende o apaga la linterna
  void _toggleLinterna() {
    _controlador.toggleTorch();
    setState(() => _lintErnaEncendida = !_lintErnaEncendida);
  }
}