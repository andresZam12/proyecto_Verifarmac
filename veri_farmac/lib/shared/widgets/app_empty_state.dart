// Estado vacío reutilizable (historial vacío, sin resultados).

import 'package:flutter/material.dart';

// Widget para cuando no hay datos que mostrar.
// Ejemplo: historial vacío, sin resultados de búsqueda.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.titulo,
    this.descripcion,
    this.accion,
  });

  final String titulo;
  final String? descripcion;

  // Widget opcional — puede ser un botón de acción
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (descripcion != null) ...[
              const SizedBox(height: 8),
              Text(
                descripcion!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (accion != null) ...[
              const SizedBox(height: 24),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}