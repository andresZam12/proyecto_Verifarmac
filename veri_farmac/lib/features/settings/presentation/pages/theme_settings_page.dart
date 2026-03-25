// Pantalla para elegir tema: Light, Dark o Sistema.
// TODO: usar ThemeNotifier de core/providers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

// Pantalla para elegir entre tema claro, oscuro o seguir el sistema.
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temaActual = ref.watch(themeNotifierProvider);

    final opciones = [
      (modo: ThemeMode.system, icono: Icons.brightness_auto_rounded,
          etiqueta: 'Seguir el sistema'),
      (modo: ThemeMode.light, icono: Icons.light_mode_rounded,
          etiqueta: 'Claro'),
      (modo: ThemeMode.dark, icono: Icons.dark_mode_rounded,
          etiqueta: 'Oscuro'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: opciones.map((opcion) {
            final seleccionado = temaActual == opcion.modo;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .cambiarTema(opcion.modo),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: seleccionado
                          ? AppColors.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                      width: seleccionado ? 2 : 0.5,
                    ),
                    color: seleccionado
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        opcion.icono,
                        color: seleccionado ? AppColors.primary : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          opcion.etiqueta,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: seleccionado ? AppColors.primary : null,
                          ),
                        ),
                      ),
                      if (seleccionado)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}