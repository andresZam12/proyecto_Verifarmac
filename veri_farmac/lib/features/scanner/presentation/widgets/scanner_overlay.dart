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
  final ScanMode mode;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(
        highlight: highlight,
        mode: mode,
        message: message,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({
    this.highlight = false,
    this.mode = ScanMode.barcode,
    this.message,
  });
  final bool     highlight;
  final ScanMode mode;
  final String?  message;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Fondo oscuro con recorte ────────────────────────────
    final darkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.58);

    final areaWidth  = mode == ScanMode.ocr
        ? size.width * 0.92
        : size.width * 0.75;
    final areaHeight = mode == ScanMode.ocr
        ? areaWidth * 0.60
        : areaWidth * 0.50;
    final left   = (size.width  - areaWidth)  / 2;
    final top    = (size.height - areaHeight) / 2;
    final scanArea = Rect.fromLTWH(left, top, areaWidth, areaHeight);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, darkPaint);

    // ── Marcadores de esquina (L-shape) ─────────────────────
    final color  = highlight ? Colors.green : AppColors.primary;
    const cLen   = 26.0; // longitud de cada brazo
    const cRad   = 16.0; // radio de la esquina redondeada del área
    const stroke = 3.5;

    final cornerPaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap   = StrokeCap.round;

    // Top-left
    _drawCorner(canvas, cornerPaint,
        Offset(left + cRad, top), Offset(left + cRad + cLen, top));
    _drawCorner(canvas, cornerPaint,
        Offset(left, top + cRad), Offset(left, top + cRad + cLen));

    // Top-right
    final right = left + areaWidth;
    _drawCorner(canvas, cornerPaint,
        Offset(right - cRad, top), Offset(right - cRad - cLen, top));
    _drawCorner(canvas, cornerPaint,
        Offset(right, top + cRad), Offset(right, top + cRad + cLen));

    // Bottom-left
    final bottom = top + areaHeight;
    _drawCorner(canvas, cornerPaint,
        Offset(left + cRad, bottom), Offset(left + cRad + cLen, bottom));
    _drawCorner(canvas, cornerPaint,
        Offset(left, bottom - cRad), Offset(left, bottom - cRad - cLen));

    // Bottom-right
    _drawCorner(canvas, cornerPaint,
        Offset(right - cRad, bottom), Offset(right - cRad - cLen, bottom));
    _drawCorner(canvas, cornerPaint,
        Offset(right, bottom - cRad), Offset(right, bottom - cRad - cLen));

    // Puntos en esquinas
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(left + cRad, top), 4, dotPaint);
    canvas.drawCircle(Offset(right - cRad, top), 4, dotPaint);
    canvas.drawCircle(Offset(left + cRad, bottom), 4, dotPaint);
    canvas.drawCircle(Offset(right - cRad, bottom), 4, dotPaint);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset a, Offset b) {
    canvas.drawLine(a, b, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.highlight != highlight || old.mode != mode;
}
