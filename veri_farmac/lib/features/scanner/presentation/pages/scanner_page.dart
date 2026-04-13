import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
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

  ScanMode _mode          = ScanMode.barcode;
  bool     _torchEnabled  = false;
  bool     _processing    = false;

  // Último valor detectado — solo se procesa cuando el usuario presiona el obturador
  String? _detectedValue;

  @override
  void dispose() {
    _controller.dispose();
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
        setState(() => _processing = false);
      }
    });

    final isAnalyzing = scannerState.status == ScannerStatus.analyzing;
    final hasTarget   = _detectedValue != null && !_processing;

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
          message: _mode == ScanMode.barcode
              ? l10n.aimAtBarcode
              : l10n.aimAtPackageText,
          highlight: hasTarget, // marco verde cuando hay algo detectado
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
              }),
            ),
          ),
        ),

        // Indicador de detección sobre el obturador
        if (hasTarget)
          Positioned(
            bottom: 148,
            left: 0,
            right: 0,
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
                  Text(
                    _mode == ScanMode.barcode
                        ? 'Código detectado — presiona para consultar'
                        : 'Texto detectado — presiona para consultar',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
              onPress:  _onShutterPressed,
              hasTarget: hasTarget,
              isLoading: isAnalyzing,
            ),
          ),
        ),
      ]),
    );
  }

  // Se llama continuamente por la cámara — solo guarda el valor, no procesa
  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null && value != _detectedValue) {
      setState(() => _detectedValue = value);
    }
  }

  // El usuario presiona el obturador — ahora sí se consulta la API
  void _onShutterPressed() {
    final value = _detectedValue;
    if (value == null || _processing) return;

    setState(() => _processing = true);

    if (_mode == ScanMode.barcode) {
      ref.read(scannerProvider.notifier).scanBarcode(value);
    } else {
      ref.read(scannerProvider.notifier).scanOcr(value);
    }
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
  });

  final VoidCallback onPress;
  final bool         hasTarget;
  final bool         isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:  80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLoading
              ? Colors.grey.withValues(alpha: 0.5)
              : hasTarget
                  ? Colors.green
                  : Colors.white.withValues(alpha: 0.85),
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasTarget ? Colors.green : Colors.white)
                  .withValues(alpha: 0.3),
              blurRadius: hasTarget ? 20 : 8,
              spreadRadius: hasTarget ? 4 : 0,
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                hasTarget
                    ? Icons.search_rounded
                    : Icons.camera_alt_rounded,
                color: hasTarget ? Colors.white : Colors.black,
                size: 32,
              ),
      ),
    );
  }
}
