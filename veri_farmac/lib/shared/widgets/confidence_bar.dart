// Barra animada que muestra el porcentaje de confianza del análisis IA.

import 'package:flutter/material.dart';

// Barra visual que muestra el nivel de confianza del análisis IA.
// Se usa en la pantalla de resultado del medicamento.
class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.confidence});

  // Value between 0.0 and 1.0
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analysis confidence',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _colorByConfidence(confidence),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 6,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _colorByConfidence(confidence),
            ),
          ),
        ),
      ],
    );
  }

  // Green if high, yellow if medium, red if low
  Color _colorByConfidence(double value) {
    if (value >= 0.7) return const Color(0xFF2E7D32); // green
    if (value >= 0.4) return const Color(0xFFF9A825); // yellow
    return const Color(0xFFC62828);                   // red
  }
}