import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/settings_tile.dart';

// Pantalla principal de ajustes con secciones de cuenta y apariencia.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temaActual = ref.watch(themeNotifierProvider);
    final idiomaActual = ref.watch(localeNotifierProvider);

    final etiquetaTema = switch (temaActual) {
      ThemeMode.light  => 'Claro',
      ThemeMode.dark   => 'Oscuro',
      ThemeMode.system => 'Seguir el sistema',
    };

    final etiquetaIdioma =
        idiomaActual?.languageCode == 'en' ? 'English' : 'Español';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          // Sección cuenta
          _Seccion(titulo: 'Cuenta'),
          SettingsTile(
            icono: Icons.person_outline_rounded,
            titulo: 'Perfil',
            subtitulo: 'Ver y editar tu información',
            alPresionar: () => context.push(AppRoutes.ajustes + '/perfil'),
          ),

          const Divider(height: 1),

          // Sección apariencia
          _Seccion(titulo: 'Apariencia'),
          SettingsTile(
            icono: Icons.palette_outlined,
            titulo: 'Tema',
            subtitulo: etiquetaTema,
            alPresionar: () => context.push(AppRoutes.ajustes + '/tema'),
          ),
          SettingsTile(
            icono: Icons.language_rounded,
            titulo: 'Idioma',
            subtitulo: etiquetaIdioma,
            alPresionar: () => context.push(AppRoutes.ajustes + '/idioma'),
          ),

          const Divider(height: 1),

          // Sección acerca de
          _Seccion(titulo: 'Acerca de'),
          SettingsTile(
            icono: Icons.info_outline_rounded,
            titulo: 'Versión',
            subtitulo: '1.0.0',
            trailing: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Encabezado de sección
class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}