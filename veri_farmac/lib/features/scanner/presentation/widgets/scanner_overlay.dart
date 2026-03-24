// Overlay visual sobre la cámara con marco y guías.
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

// Marco visual que se dibuja encima de la cámara.
// Oscurece los bordes y deja un área clara en el centro
// para que el usuario sepa dónde apuntar.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key, this.mensaje});

  final String? mensaje;

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
            mensaje ?? 'Apunta al código del medicamento',
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
    final pinturaNegra = Paint()..color = Colors.black.withOpacity(0.6);

    // Área de escaneo — rectángulo centrado
    final ancho  = size.width * 0.75;
    final alto   = ancho * 0.5;
    final left   = (size.width - ancho) / 2;
    final top    = (size.height - alto) / 2;
    final areaEscaneo = Rect.fromLTWH(left, top, ancho, alto);

    // Dibuja el fondo oscuro quitando el área de escaneo
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(areaEscaneo, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, pinturaNegra);

    // Dibuja el borde del área de escaneo en color cyan
    final pinturaBorde = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(areaEscaneo, const Radius.circular(12)),
      pinturaBorde,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
