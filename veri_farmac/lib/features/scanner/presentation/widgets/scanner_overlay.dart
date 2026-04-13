// Marco visual sobre la cámara con área de escaneo resaltada.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    this.message,
    this.highlight = false,
  });

  final String? message;
  // true cuando hay un código detectado — cambia el borde a verde
  final bool    highlight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro con el recorte del área de escaneo
        CustomPaint(
          painter: _OverlayPainter(highlight: highlight),
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
  const _OverlayPainter({this.highlight = false});
  final bool highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final width    = size.width * 0.75;
    final height   = width * 0.5;
    final left     = (size.width  - width)  / 2;
    final top      = (size.height - height) / 2;
    final scanArea = Rect.fromLTWH(left, top, width, height);

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
  bool shouldRepaint(_OverlayPainter old) => old.highlight != highlight;
}
