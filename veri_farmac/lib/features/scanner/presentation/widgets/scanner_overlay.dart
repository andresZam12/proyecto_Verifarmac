// Marco visual sobre la cámara con área de escaneo resaltada.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'scan_mode_toggle.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    this.message,
    this.highlight = false,
    this.mode = ScanMode.barcode,
  });

  final String?  message;
  final bool     highlight;
  // El modo determina el tamaño del área: OCR usa un rectángulo más grande
  final ScanMode mode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro con el recorte del área de escaneo
        CustomPaint(
          painter: _OverlayPainter(highlight: highlight, mode: mode),
          child: const SizedBox.expand(),
        ),

        // Mensaje de instrucciones
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Text(
            message ?? 'Aim at the medicine code',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({
    this.highlight = false,
    this.mode = ScanMode.barcode,
  });
  final bool     highlight;
  final ScanMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    // OCR necesita un área más grande para capturar texto del empaque
    final areaWidth  = mode == ScanMode.ocr ? size.width * 0.92 : size.width * 0.75;
    final areaHeight = mode == ScanMode.ocr ? areaWidth * 0.60  : areaWidth * 0.50;
    final left       = (size.width  - areaWidth)  / 2;
    final top        = (size.height - areaHeight) / 2;
    final scanArea   = Rect.fromLTWH(left, top, areaWidth, areaHeight);

    // Fondo oscuro con recorte
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, darkPaint);

    // Borde: azul normal, verde cuando hay detección
    final borderPaint = Paint()
      ..color       = highlight ? Colors.green : AppColors.primary
      ..style       = PaintingStyle.stroke
      ..strokeWidth = highlight ? 3.5 : 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.highlight != highlight || old.mode != mode;
}
