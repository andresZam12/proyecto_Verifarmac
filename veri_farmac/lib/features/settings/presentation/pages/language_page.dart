import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

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
            const SizedBox(height: 20),
            Text('Elige tu idioma',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            _OpcionIdioma(
              bandera: '',
              nombre: 'Español',
              seleccionado: localeActual?.languageCode == 'es' || localeActual == null,
              alPresionar: () async {
                ref.read(localeNotifierProvider.notifier).cambiarIdioma(const Locale('es'));
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 12),
            _OpcionIdioma(
              bandera: '',
              nombre: 'English',
              seleccionado: localeActual?.languageCode == 'en',
              alPresionar: () async {
                ref.read(localeNotifierProvider.notifier).cambiarIdioma(const Locale('en'));
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
            color: seleccionado ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: seleccionado ? 2 : 0.5,
          ),
          color: seleccionado ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(children: [
          Text(bandera, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(child: Text(nombre,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: seleccionado ? AppColors.primary : null))),
          if (seleccionado)
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }
}
