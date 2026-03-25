// Indicador de carga reutilizable.
import 'package:flutter/material.dart';

// Widget de carga que se usa mientras espera una respuesta.
// Ejemplo: mientras consulta el INVIMA o carga el historial.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.mensaje});

  // Mensaje opcional debajo del spinner
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
