// Tile reutilizable para cada opción de ajustes.
// TODO: implementar con ícono, título, subtitle, trailing y isDestructive

import 'package:flutter/material.dart';

// Tile reutilizable para cada opción de la pantalla de ajustes.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    this.alPresionar,
    this.esDestructivo = false,
  });

  final IconData     icono;
  final String       titulo;
  final String?      subtitulo;
  final Widget?      trailing;
  final VoidCallback? alPresionar;
  final bool         esDestructivo; // true para opciones como "Cerrar sesión"

  @override
  Widget build(BuildContext context) {
    final color = esDestructivo
        ? Colors.red
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icono, color: esDestructivo ? Colors.red : null),
      title: Text(
        titulo,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitulo != null ? Text(subtitulo!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: alPresionar,
    );
  }
}