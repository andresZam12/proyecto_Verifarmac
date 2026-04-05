// Marco visual sobre la cámara con área de escaneo resaltada.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro con el recorte del área de escaneo
        CustomPaint(
          painter: _OverlayPainter(),
          child: const SizedBox.expand(),
        ),

        // Mensaje de instrucciones en la parte inferior
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

// Dibuja el fondo oscuro con el recorte rectangular del centro
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    // Área de escaneo — rectángulo centrado
    final width     = size.width * 0.75;
    final height    = width * 0.5;
    final left      = (size.width  - width)  / 2;
    final top       = (size.height - height) / 2;
    final scanArea  = Rect.fromLTWH(left, top, width, height);

    // Dibuja el fondo oscuro quitando el área de escaneo
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, darkPaint);

    // Dibuja el borde del área de escaneo
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
