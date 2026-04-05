// Tile reutilizable para cada opción de la pantalla de ajustes.
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onPress,
    this.isDestructive = false,
  });

  final IconData      icon;
  final String        title;
  final String?       subtitle;
  final Widget?       trailing;
  final VoidCallback? onPress;
  final bool          isDestructive; // true para opciones como "Cerrar sesión"

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onPress,
    );
  }
}
