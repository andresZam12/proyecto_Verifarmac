// Indicador de carga reutilizable.
import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  // Mensaje opcional debajo del spinner
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
