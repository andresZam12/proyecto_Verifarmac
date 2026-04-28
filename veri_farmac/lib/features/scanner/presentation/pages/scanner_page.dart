import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/models/history_entry_model.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_mode_toggle.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  // ── Barcode ──────────────────────────────────────────────────
  final _barcodeController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  // ── OCR ──────────────────────────────────────────────────────
  final _ocr = OcrDataSource();
  CameraController? _camController;

  // ── Estado ───────────────────────────────────────────────────
  ScanMode _mode         = ScanMode.barcode;
  bool     _torchEnabled = false;
  bool     _processing   = false;
  String?  _detectedValue; // solo barcode mode

  // ── Ciclo de vida ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeController.dispose();
    _camController?.dispose();
    _ocr.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _camController?.dispose();
    } else if (state == AppLifecycleState.resumed && _mode == ScanMode.ocr) {
      _startOcrCamera();
    }
  }

  // ── Cámara OCR ───────────────────────────────────────────────

  Future<void> _startOcrCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) { ctrl.dispose(); return; }
      setState(() => _camController = ctrl);
    } catch (e) {
      debugPrint('[OCR cam] Error iniciando cámara: $e');
    }
  }

  Future<void> _stopOcrCamera() async {
    final ctrl = _camController;
    _camController = null;
    await ctrl?.dispose();
  }

  // ── Cambio de modo ───────────────────────────────────────────

  Future<void> _changeMode(ScanMode mode) async {
    if (mode == _mode) return;
    setState(() {
      _mode          = mode;
      _detectedValue = null;
      _processing    = false;
    });
    ref.read(scannerProvider.notifier).reset();

    if (mode == ScanMode.ocr) {
      await _barcodeController.stop();
      await _startOcrCamera();
    } else {
      await _stopOcrCamera();
      await _barcodeController.start();
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    final l10n         = context.l10n;

    ref.listen(scannerProvider, (_, current) {
      if (current.status == ScannerStatus.success && current.result != null) {
        context.push(AppRoutes.medicine, extra: current.result);
        ref.read(scannerProvider.notifier).reset();
        setState(() { _processing = false; _detectedValue = null; });
      }
      if (current.status == ScannerStatus.error) {
        setState(() { _processing = false; _detectedValue = null; });
        // Si hay un resultado (no excepción de red), guardar como "no encontrado"
        final r = current.result;
        if (r != null) {
          _saveNotFound(r.scannedValue);
        }
      }
    });

    final isAnalyzing = scannerState.status == ScannerStatus.analyzing;
    final hasTarget   = _mode == ScanMode.ocr
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

        // ── Preview de cámara ───────────────────────────────
        if (_mode == ScanMode.ocr &&
            _camController != null &&
            _camController!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width:  _camController!.value.previewSize!.height,
                height: _camController!.value.previewSize!.width,
                child: CameraPreview(_camController!),
              ),
            ),
          )
        else if (_mode == ScanMode.ocr)
          // Mientras la cámara OCR inicializa
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else
          MobileScanner(
            controller: _barcodeController,
            onDetect:   _onDetect,
          ),

        // ── Overlay de encuadre ─────────────────────────────
        ScannerOverlay(
          mode:      _mode,
          message:   _mode == ScanMode.barcode
              ? l10n.aimAtBarcode
              : l10n.aimAtPackageText,
          highlight: _mode == ScanMode.barcode && hasTarget,
        ),

        // ── Toggle de modo ──────────────────────────────────
        Positioned(
          top: 16, left: 0, right: 0,
          child: Center(
            child: ScanModeToggle(
              currentMode: _mode,
              onChange:    _changeMode,
            ),
          ),
        ),

        // ── Indicador barcode detectado ─────────────────────
        if (_mode == ScanMode.barcode && hasTarget)
          Positioned(
            bottom: 148, left: 0, right: 0,
            child: Center(
              child: _Pill(
                color: Colors.green,
                icon: Icons.check_circle_rounded,
                text: 'Código detectado — presiona para consultar',
              ),
            ),
          ),

        // ── Indicador modo OCR listo ────────────────────────
        if (_mode == ScanMode.ocr && !_processing &&
            scannerState.status != ScannerStatus.error)
          Positioned(
            bottom: 148, left: 0, right: 0,
            child: Center(
              child: _Pill(
                color: Colors.blue,
                icon: Icons.document_scanner_rounded,
                text: 'Apunta al número INVIMA y presiona',
              ),
            ),
          ),

        // ── Cargando ────────────────────────────────────────
        if (isAnalyzing)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: AppLoading(message: l10n.analyzing),
          ),

        // ── Error overlay ────────────────────────────────────
        if (scannerState.status == ScannerStatus.error)
          _ScanAlertOverlay(
            error: scannerState.error ?? '',
            onDismiss: () => ref.read(scannerProvider.notifier).reset(),
          ),

        // ── Obturador ───────────────────────────────────────
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

  // ── Handlers ─────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_processing || _mode != ScanMode.barcode) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null && value != _detectedValue) {
      setState(() => _detectedValue = value);
    }
  }

  Future<void> _onShutterPressed() async {
    if (_processing) return;

    if (_mode == ScanMode.barcode) {
      final value = _detectedValue;
      if (value == null) return;
      setState(() => _processing = true);
      ref.read(scannerProvider.notifier).scanBarcode(value);
      return;
    }

    // ── Modo OCR: captura frame y extrae texto ────────────
    final cam = _camController;
    if (cam == null || !cam.value.isInitialized) return;
    setState(() => _processing = true);

    try {
      final photo = await cam.takePicture();
      final text  = await _ocr.extractText(photo.path);
      debugPrint('[OCR] Texto extraído: $text');

      if (text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se detectó texto. Mejora la iluminación y el enfoque.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _processing = false);
        return;
      }
      ref.read(scannerProvider.notifier).scanOcr(text);
    } catch (e) {
      debugPrint('[OCR] Error capturando foto: $e');
      setState(() => _processing = false);
    }
  }

  Future<void> _saveNotFound(String scannedValue) async {
    try {
      final entry = HistoryEntryModel(
        id:             DateTime.now().millisecondsSinceEpoch.toString(),
        medicineName:   scannedValue,
        sanitaryRecord: '—',
        status:         'no_encontrado',
        method:         _mode.name,
        createdAt:      DateTime.now(),
        confidence:     0.0,
      );
      await HistoryLocalDataSource().save(entry);
      ref.read(dashboardProvider.notifier).load();
    } catch (_) {}
  }

  void _toggleTorch() {
    if (_mode == ScanMode.barcode) {
      _barcodeController.toggleTorch();
    } else {
      _camController?.setFlashMode(
        _torchEnabled ? FlashMode.off : FlashMode.torch,
      );
    }
    setState(() => _torchEnabled = !_torchEnabled);
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _ScanAlertOverlay extends StatelessWidget {
  const _ScanAlertOverlay({required this.error, required this.onDismiss});
  final String       error;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    // Determina si el error es "no encontrado" o un fallo técnico
    final isNotFound = !error.contains('Error') && !error.contains('error');

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.82),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNotFound
                      ? Icons.search_off_rounded
                      : Icons.warning_amber_rounded,
                  color: isNotFound ? Colors.amber : Colors.orange,
                  size: 72,
                ),
                const SizedBox(height: 20),
                Text(
                  isNotFound
                      ? 'No encontrado en INVIMA'
                      : 'No se pudo procesar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isNotFound
                      ? 'Verifica el origen del medicamento\ny mantente alerta.'
                      : 'Intenta de nuevo con mejor iluminación\no enfoque.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear otro'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.icon, required this.text});
  final Color    color;
  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}

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
    final Color color;
    if (isLoading) {
      color = Colors.grey.withValues(alpha: 0.5);
    } else if (isOcr) {
      color = Colors.blue.withValues(alpha: 0.9);
    } else if (hasTarget) {
      color = Colors.green;
    } else {
      color = Colors.white.withValues(alpha: 0.85);
    }

    return GestureDetector(
      onTap: isLoading ? null : onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80, height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius:   (hasTarget || isOcr) ? 20 : 8,
              spreadRadius: (hasTarget || isOcr) ? 4  : 0,
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3,
                ),
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
