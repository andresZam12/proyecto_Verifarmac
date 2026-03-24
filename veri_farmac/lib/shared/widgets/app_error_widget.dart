// Widget de error con botón de reintentar.

import 'package:flutter/material.dart';

// Widget de error reutilizable.
// Se usa cuando una llamada a la API falla o no hay conexión.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.mensaje,
    this.alReintentar,
  });

  final String mensaje;

  // Callback opcional — si se pasa, muestra el botón "Reintentar"
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (alReintentar != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}