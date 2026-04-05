// Temas light y dark de la aplicación.
import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// COLORES
// ─────────────────────────────────────────

class AppColors {
  AppColors._();

  // Color principal de la app
  static const primary      = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF1E88E5);

  // Colores según el estado del medicamento
  static const valid      = Color(0xFF2E7D32); // verde
  static const expired    = Color(0xFFC62828); // rojo
  static const invalid    = Color(0xFFE65100); // naranja
  static const suspicious = Color(0xFF6A1B9A); // morado
  static const unknown    = Color(0xFF546E7A); // gris azulado

  // Fondos modo claro
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurface    = Color(0xFFFFFFFF);
  static const lightBorder     = Color(0xFFE0E0E0);

  // Fondos modo oscuro
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurface    = Color(0xFF1A1C1E);
  static const darkBorder     = Color(0xFF2E3138);
}

// ─────────────────────────────────────────
// TEMAS
// ─────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // Tema claro
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    // AppBar transparente y sin sombra
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primary,
    ),

    // Tarjetas con borde sutil
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
      ),
    ),

    // Botón principal
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  // Tema oscuro
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primaryLight,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
