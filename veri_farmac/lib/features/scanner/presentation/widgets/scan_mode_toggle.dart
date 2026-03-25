// Toggle para cambiar entre modo Barcode y OCR.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

// Modos de escaneo disponibles
enum ModoEscaneo { barcode, ocr }

// Toggle que permite cambiar entre escaneo por código de barras y por texto OCR.
class ScanModeToggle extends StatelessWidget {
  const ScanModeToggle({
    super.key,
    required this.modoActual,
    required this.alCambiar,
  });

  final ModoEscaneo modoActual;
  final ValueChanged<ModoEscaneo> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BotonModo(
            icono: Icons.qr_code_scanner_rounded,
            etiqueta: 'Código',
            seleccionado: modoActual == ModoEscaneo.barcode,
            alPresionar: () => alCambiar(ModoEscaneo.barcode),
          ),
          const SizedBox(width: 4),
          _BotonModo(
            icono: Icons.text_fields_rounded,
            etiqueta: 'Texto',
            seleccionado: modoActual == ModoEscaneo.ocr,
            alPresionar: () => alCambiar(ModoEscaneo.ocr),
          ),
        ],
      ),
    );
  }
}

// Botón individual del toggle
class _BotonModo extends StatelessWidget {
  const _BotonModo({
    required this.icono,
    required this.etiqueta,
    required this.seleccionado,
    required this.alPresionar,
  });

  final IconData icono;
  final String   etiqueta;
  final bool     seleccionado;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icono, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
