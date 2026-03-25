// Pantalla de selección de idioma (onboarding y settings).
// TODO: mostrar opciones ES/EN con banderas y guardar en SharedPreferences

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

// Pantalla de selección de idioma.
// Se usa en el onboarding (primera vez) y en ajustes.
class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeActual = ref.watch(localeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Idioma')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Opción español
            _OpcionIdioma(
              bandera: '🇨🇴',
              nombre: 'Español',
              seleccionado: localeActual?.languageCode == 'es' ||
                  localeActual == null,
              alPresionar: () => ref
                  .read(localeNotifierProvider.notifier)
                  .cambiarIdioma(const Locale('es')),
            ),

            const SizedBox(height: 12),

            // Opción inglés
            _OpcionIdioma(
              bandera: '🇺🇸',
              nombre: 'English',
              seleccionado: localeActual?.languageCode == 'en',
              alPresionar: () => ref
                  .read(localeNotifierProvider.notifier)
                  .cambiarIdioma(const Locale('en')),
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de opción de idioma
class _OpcionIdioma extends StatelessWidget {
  const _OpcionIdioma({
    required this.bandera,
    required this.nombre,
    required this.seleccionado,
    required this.alPresionar,
  });

  final String       bandera;
  final String       nombre;
  final bool         seleccionado;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: seleccionado ? 2 : 0.5,
          ),
          color: seleccionado
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(bandera, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nombre,
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
    );
  }
}