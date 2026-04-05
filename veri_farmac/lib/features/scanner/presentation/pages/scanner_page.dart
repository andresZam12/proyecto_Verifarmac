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
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  ScanMode _mode             = ScanMode.barcode;
  bool     _torchEnabled     = false;
  bool     _alreadyProcessed = false;

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
        _alreadyProcessed = false;
      }
    });

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
        MobileScanner(controller: _controller, onDetect: _onDetect),
        ScannerOverlay(
          message: _mode == ScanMode.barcode
              ? l10n.aimAtBarcode
              : l10n.aimAtPackageText,
        ),
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: ScanModeToggle(
              currentMode: _mode,
              onChange: (mode) => setState(() => _mode = mode),
            ),
          ),
        ),
        if (scannerState.status == ScannerStatus.analyzing)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: AppLoading(message: l10n.analyzing),
          ),
        if (scannerState.status == ScannerStatus.error)
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
                scannerState.error ?? 'Error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ]),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_alreadyProcessed) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;
    _alreadyProcessed = true;
    if (_mode == ScanMode.barcode) {
      ref.read(scannerProvider.notifier).scanBarcode(barcode);
    } else {
      ref.read(scannerProvider.notifier).scanOcr(barcode);
    }
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }
}
