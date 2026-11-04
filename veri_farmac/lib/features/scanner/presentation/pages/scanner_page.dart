import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../history/data/models/history_entry_model.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../scanner/domain/entities/scan_result.dart';
import '../../data/datasources/claude_ai_datasource.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_mode_toggle.dart';

// ── Tokens de color ───────────────────────────────────────────
const _kPrimary = Color(0xFF00478D);

// ─────────────────────────────────────────────────────────────

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  final _ocr = OcrDataSource();
  CameraController?        _camController;
  MobileScannerController? _burstController;

  ScanMode _mode         = ScanMode.ocr;
  bool     _torchEnabled = false;
  bool     _processing   = false;
  String?  _capturedPhotoPath; // congela la foto tomada mientras se analiza (OCR/IA)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camController?.dispose();
    _burstController?.dispose();
    _ocr.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _camController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  // ── Cámara ───────────────────────────────────────────────────
  // Los 3 modos (código de barras, OCR, IA visual) comparten la misma
  // cámara y el mismo obturador: se toma una foto quieta y luego se
  // decide qué analizar según el modo seleccionado. Así se evita que
  // un escaneo en vivo (p. ej. de código de barras) capture datos
  // erróneos mientras el usuario todavía está apuntando/moviendo el celular.

  Future<void> _startCamera() async {
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
      debugPrint('[Scanner cam] Error iniciando cámara: $e');
    }
  }

  void _onModeChange(ScanMode mode) {
    if (mode == _mode || _processing) return;
    setState(() => _mode = mode);
    ref.read(scannerProvider.notifier).reset();
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
        setState(() { _processing = false; _capturedPhotoPath = null; });
      }
      if (current.status == ScannerStatus.error) {
        setState(() { _processing = false; _capturedPhotoPath = null; });
        final r = current.result;
        if (r != null) _saveNotFound(r);
      }
    });

    final isAnalyzing  = scannerState.status == ScannerStatus.analyzing || _processing;
    final camReady     = _camController != null &&
                        _camController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // ── Preview: ráfaga en vivo de código de barras ──────
        if (_burstController != null)
          MobileScanner(controller: _burstController, fit: BoxFit.cover)

        // ── Preview: foto congelada mientras se analiza (OCR/IA) ──
        else if (_capturedPhotoPath != null)
          SizedBox.expand(
            child: Image.file(File(_capturedPhotoPath!), fit: BoxFit.cover),
          )

        // ── Preview de cámara en vivo ─────────────────────────
        else if (camReady)
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
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // ── Overlay de encuadre ──────────────────────────────
        ScannerOverlay(mode: _mode),

        // ── Gradiente superior ───────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0, height: 160,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Gradiente inferior ───────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0, height: 230,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end:   Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),

        // ── Top bar ──────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              _IconCircleButton(
                icon:  Icons.arrow_back_rounded,
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.dashboard),
              ),
              const Spacer(),
              Text(
                l10n.scanner,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              _IconCircleButton(
                icon:   _torchEnabled
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                onTap:  _toggleTorch,
                active: _torchEnabled,
              ),
            ]),
          ),
        ),

        // ── Toggle de modo (código de barras / OCR / IA visual) ──
        Positioned(
          top: 72, left: 0, right: 0,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ScanModeToggle(currentMode: _mode, onChange: _onModeChange),
            ),
          ),
        ),

        // ── Pill: instrucción ────────────────────────────────
        if (!_processing && scannerState.status != ScannerStatus.error)
          Positioned(
            bottom: 150, left: 32, right: 32,
            child: _StatusPill(
              color: _kPrimary,
              icon:  switch (_mode) {
                ScanMode.barcode => Icons.qr_code_scanner_rounded,
                ScanMode.visual  => Icons.auto_awesome_rounded,
                ScanMode.ocr     => Icons.document_scanner_rounded,
              },
              text:  switch (_mode) {
                ScanMode.barcode => l10n.aimAtBarcode,
                ScanMode.visual  => l10n.aimAtPackageVisual,
                ScanMode.ocr     => l10n.aimAtPackageText,
              },
            ),
          ),

        // ── Cargando ─────────────────────────────────────────
        if (isAnalyzing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.72),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 56, height: 56,
                      child: CircularProgressIndicator(
                        color: _kPrimary, strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.analyzing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Error overlay ────────────────────────────────────
        if (scannerState.status == ScannerStatus.error)
          _ScanAlertOverlay(
            error:     scannerState.error ?? '',
            onDismiss: () => ref.read(scannerProvider.notifier).reset(),
          ),

        // ── Shutter button (igual en los 3 modos: primero se
        // toma la foto quieta, luego se analiza según el modo) ──
        Positioned(
          bottom: 52, left: 0, right: 0,
          child: Center(
            child: _ShutterButton(
              onPress:   _onShutterPressed,
              isLoading: isAnalyzing,
              icon:      switch (_mode) {
                ScanMode.barcode => Icons.qr_code_scanner_rounded,
                ScanMode.visual  => Icons.auto_awesome_rounded,
                ScanMode.ocr     => Icons.document_scanner_rounded,
              },
            ),
          ),
        ),
      ]),
    );
  }

  // ── Handlers ─────────────────────────────────────────────────

  Future<void> _onShutterPressed() async {
    if (_processing) return;

    if (_mode == ScanMode.visual && !ClaudeAiDataSource.isConfigured) {
      _showSnack(
        'El análisis con IA no está configurado en esta compilación '
        '(falta CLAUDE_API_KEY).',
      );
      return;
    }

    if (_mode == ScanMode.barcode) {
      await _scanBarcodeBurst();
      return;
    }

    final cam = _camController;
    if (cam == null || !cam.value.isInitialized) return;
    setState(() => _processing = true);

    try {
      final photo = await cam.takePicture();
      // Congela la foto tomada en pantalla — antes no había ninguna señal
      // visual de que el obturador sí había capturado algo.
      setState(() => _capturedPhotoPath = photo.path);

      if (_mode == ScanMode.visual) {
        ref.read(scannerProvider.notifier).analyzeImage(photo.path);
      } else {
        await _analyzeOcrStill(photo.path);
      }
    } catch (e) {
      debugPrint('[Scanner] Error capturando foto: $e');
      setState(() { _processing = false; _capturedPhotoPath = null; });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  Future<void> _analyzeOcrStill(String imagePath) async {
    final text = await _ocr.extractText(imagePath);
    debugPrint('[OCR] Texto extraído: $text');

    if (text.trim().isEmpty) {
      _showSnack('No se detectó texto. Mejora la iluminación y el enfoque.');
      setState(() { _processing = false; _capturedPhotoPath = null; });
      return;
    }
    ref.read(scannerProvider.notifier).scanOcr(text);
  }

  // Al presionar el obturador en modo código de barras se arranca una
  // ráfaga breve de detección en vivo (el motor de ML Kit vía mobile_scanner
  // reintenta en varios frames y ajusta foco), en vez de analizar una sola
  // foto estática — con una sola foto fallaba con la mayoría de códigos
  // reales. La cámara normal se libera mientras dura la ráfaga para no
  // competir por el hardware con mobile_scanner, y se recupera al terminar.
  Future<void> _scanBarcodeBurst() async {
    setState(() => _processing = true);

    await _camController?.dispose();
    _camController = null;

    // autoStart (por defecto true) hace que la propia cámara arranque en
    // cuanto el widget MobileScanner se monta — no se llama start() a mano
    // aquí porque hacerlo antes de que el widget exista en el árbol no
    // tenía efecto (la cámara nunca llegaba a activarse a tiempo).
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    final completer = Completer<String?>();
    final sub = controller.barcodes.listen((capture) {
      final code = capture.barcodes.isNotEmpty
          ? capture.barcodes.first.rawValue
          : null;
      if (code != null && code.isNotEmpty && !completer.isCompleted) {
        completer.complete(code);
      }
    });

    if (mounted) setState(() => _burstController = controller);

    String? code;
    try {
      code = await completer.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint('[Scanner] Error en ráfaga de código de barras: $e');
    } finally {
      await sub.cancel();
      await controller.dispose();
      if (mounted) setState(() => _burstController = null);
    }

    await _startCamera(); // recupera la cámara normal para el próximo intento

    if (code == null || code.isEmpty) {
      _showSnack(
        'No se detectó ningún código de barras. Mantén el celular quieto '
        'y el código centrado.',
      );
      setState(() => _processing = false);
      return;
    }
    ref.read(scannerProvider.notifier).scanBarcode(code);
  }

  Future<void> _saveNotFound(ScanResult result) async {
    try {
      final entry = HistoryEntryModel(
        id:             DateTime.now().millisecondsSinceEpoch.toString(),
        medicineName:   result.scannedValue,
        sanitaryRecord: '—',
        status:         'no_encontrado',
        method:         result.method.name,
        createdAt:      DateTime.now(),
        confidence:     0.0,
      );
      await ref.read(historyProvider.notifier).save(entry);
      ref.read(dashboardProvider.notifier).load();
    } catch (_) {}
  }

  void _toggleTorch() {
    _camController?.setFlashMode(
      _torchEnabled ? FlashMode.off : FlashMode.torch,
    );
    setState(() => _torchEnabled = !_torchEnabled);
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  final IconData     icon;
  final VoidCallback onTap;
  final bool         active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: Colors.white.withValues(alpha: active ? 0.6 : 0.2),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.icon,
    required this.text,
  });
  final Color    color;
  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ScanAlertOverlay extends StatelessWidget {
  const _ScanAlertOverlay({required this.error, required this.onDismiss});
  final String       error;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isNotFound = !error.contains('Error') && !error.contains('error');
    final iconColor  = isNotFound ? Colors.amber : Colors.orange;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.90),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    isNotFound
                        ? Icons.search_off_rounded
                        : Icons.warning_amber_rounded,
                    color: iconColor,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
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
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 15,
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: const Text(
                      'Escanear otro',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({
    required this.onPress,
    required this.isLoading,
    this.icon = Icons.document_scanner_rounded,
  });
  final VoidCallback onPress;
  final bool         isLoading;
  final IconData     icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLoading
                    ? Colors.white.withValues(alpha: 0.3)
                    : _kPrimary,
                width: 3.5,
              ),
            ),
          ),
          // Inner circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLoading
                  ? Colors.white.withValues(alpha: 0.3)
                  : _kPrimary,
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: _kPrimary.withValues(alpha: 0.45),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ],
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5,
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ],
      ),
    );
  }
}
