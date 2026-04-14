import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../medicine_detail/data/datasources/invima_api_datasource.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_mode_toggle.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  // OCR: ML Kit text recognizer + image picker
  final _ocr        = OcrDataSource();
  final _picker     = ImagePicker();

  ScanMode _mode         = ScanMode.barcode;
  bool     _torchEnabled = false;
  bool     _processing   = false;

  // Solo usado en modo barcode — valor del último código detectado
  String? _detectedValue;

  @override
  void dispose() {
    _controller.dispose();
    _ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    final l10n         = context.l10n;

    ref.listen(scannerProvider, (_, current) {
      if (current.status == ScannerStatus.success && current.result != null) {
        context.push(AppRoutes.medicine, extra: current.result);
        ref.read(scannerProvider.notifier).reset();
        setState(() {
          _processing    = false;
          _detectedValue = null;
        });
      }
      if (current.status == ScannerStatus.error) {
        setState(() {
          _processing    = false;
          _detectedValue = null;
        });
      }
    });

    final isAnalyzing = scannerState.status == ScannerStatus.analyzing;

    // En modo barcode: necesita código detectado para activar el obturador.
    // En modo OCR: el obturador siempre está activo — captura imagen al pulsar.
    final hasTarget = _mode == ScanMode.ocr
        ? !_processing
        : (_detectedValue != null && !_processing);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(l10n.scan),
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(
              _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(children: [

        // Cámara — siempre activa para previsualización
        MobileScanner(
          controller: _controller,
          onDetect:   _onDetect,
        ),

        // Marco de encuadre con mensaje de instrucción
        ScannerOverlay(
          mode:      _mode,
          message:   _mode == ScanMode.barcode
              ? l10n.aimAtBarcode
              : l10n.aimAtPackageText,
          highlight: _mode == ScanMode.barcode && hasTarget,
        ),

        // Toggle de modo en la parte superior
        Positioned(
          top: 16, left: 0, right: 0,
          child: Center(
            child: ScanModeToggle(
              currentMode: _mode,
              onChange:    (mode) => setState(() {
                _mode          = mode;
                _detectedValue = null;
                ref.read(scannerProvider.notifier).reset();
              }),
            ),
          ),
        ),

        // Indicador de detección (solo en modo barcode)
        if (_mode == ScanMode.barcode && hasTarget)
          Positioned(
            bottom: 148,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Código detectado — presiona para consultar',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ]),
              ),
            ),
          ),

        // Indicador de modo OCR
        if (_mode == ScanMode.ocr && !_processing)
          Positioned(
            bottom: 148,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Apunta al número INVIMA y presiona',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ]),
              ),
            ),
          ),

        // Overlay de carga mientras consulta la API
        if (isAnalyzing)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: AppLoading(message: l10n.analyzing),
          ),

        // Error de consulta
        if (scannerState.status == ScannerStatus.error)
          Positioned(
            bottom: 148,
            left: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                scannerState.error ?? 'Error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

        // ── Obturador ──────────────────────────────────────────
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Center(
            child: _ShutterButton(
              onPress:   _onShutterPressed,
              hasTarget: hasTarget,
              isLoading: isAnalyzing,
              isOcr:     _mode == ScanMode.ocr,
            ),
          ),
        ),
      ]),
    );
  }

  // Barcode mode — solo guarda el valor detectado, no procesa
  void _onDetect(BarcodeCapture capture) {
    if (_processing || _mode != ScanMode.barcode) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null && value != _detectedValue) {
      setState(() => _detectedValue = value);
    }
  }

  // Obturador presionado
  Future<void> _onShutterPressed() async {
    if (_processing) return;

    if (_mode == ScanMode.barcode) {
      // Modo barcode: usa el valor ya detectado
      final value = _detectedValue;
      if (value == null) return;
      setState(() => _processing = true);
      ref.read(scannerProvider.notifier).scanBarcode(value);
    } else {
      // Modo OCR: captura foto con la cámara nativa, luego extrae texto con ML Kit
      setState(() => _processing = true);
      try {
        final photo = await _picker.pickImage(
          source:       ImageSource.camera,
          imageQuality: 90,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (photo == null) {
          // Usuario canceló
          setState(() => _processing = false);
          return;
        }
        final text = await _ocr.extractText(photo.path);
        debugPrint('[OCR] Texto extraído: $text');
        if (text.trim().isEmpty) {
          ref.read(scannerProvider.notifier).reset();
          setState(() => _processing = false);
          _showOcrEmptyError();
          return;
        }
        ref.read(scannerProvider.notifier).scanOcr(text);
      } catch (e) {
        debugPrint('[OCR] Error capturando imagen: $e');
        setState(() => _processing = false);
      }
    }
  }

  void _showOcrEmptyError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se detectó texto. Asegúrate de que el empaque esté bien iluminado.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }
}

// ── Botón obturador ────────────────────────────────────────────────────────
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.onPress,
    required this.hasTarget,
    required this.isLoading,
    required this.isOcr,
  });

  final VoidCallback onPress;
  final bool         hasTarget;
  final bool         isLoading;
  final bool         isOcr;

  @override
  Widget build(BuildContext context) {
    // Color del botón: gris=cargando, verde=barcode detectado, azul=OCR listo, blanco=esperando
    final Color buttonColor;
    if (isLoading) {
      buttonColor = Colors.grey.withValues(alpha: 0.5);
    } else if (isOcr) {
      buttonColor = Colors.blue.withValues(alpha: 0.9);
    } else if (hasTarget) {
      buttonColor = Colors.green;
    } else {
      buttonColor = Colors.white.withValues(alpha: 0.85);
    }

    return GestureDetector(
      onTap: isLoading ? null : onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: buttonColor,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.4),
              blurRadius:  (hasTarget || isOcr) ? 20 : 8,
              spreadRadius: (hasTarget || isOcr) ? 4  : 0,
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Icon(
                isOcr
                    ? Icons.document_scanner_rounded
                    : hasTarget
                        ? Icons.search_rounded
                        : Icons.camera_alt_rounded,
                color: (hasTarget || isOcr) ? Colors.white : Colors.black,
                size: 32,
              ),
      ),
    );
  }
}
