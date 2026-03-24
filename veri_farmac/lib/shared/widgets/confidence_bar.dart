// Barra animada que muestra el porcentaje de confianza del análisis IA.

import 'package:flutter/material.dart';

// Barra visual que muestra el nivel de confianza del análisis IA.
// Se usa en la pantalla de resultado del medicamento.
class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.confianza});

  // Valor entre 0.0 y 1.0
  final double confianza;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confianza del análisis',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            Text(
              '${(confianza * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _colorSegunConfianza(confianza),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confianza,
            minHeight: 6,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _colorSegunConfianza(confianza),
            ),
          ),
        ),
      ],
    );
  }

  // Verde si es alta, amarillo si es media, rojo si es baja
  Color _colorSegunConfianza(double valor) {
    if (valor >= 0.7) return const Color(0xFF2E7D32); // verde
    if (valor >= 0.4) return const Color(0xFFF9A825); // amarillo
    return const Color(0xFFC62828);                   // rojo
  }
}