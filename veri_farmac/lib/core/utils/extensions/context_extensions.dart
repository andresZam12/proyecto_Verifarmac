import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Acceso rápido al tema actual
  ThemeData get tema => Theme.of(this);

  // Acceso rápido a los colores del tema
  ColorScheme get colores => Theme.of(this).colorScheme;

  // Verifica si está en modo oscuro
  bool get esModoOscuro => Theme.of(this).brightness == Brightness.dark;

  // Tamaño de la pantalla
  Size get tamañoPantalla => MediaQuery.sizeOf(this);

  // Muestra un snackbar rápido
  // Ejemplo: context.mostrarMensaje('Guardado correctamente')
  void mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? colores.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}