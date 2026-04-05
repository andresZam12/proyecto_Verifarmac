// Maneja ThemeMode (light / dark / system) y Locale con Riverpod.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

// Claves para guardar en SharedPreferences — centralizadas en AppStrings
const _themeKey  = AppStrings.prefThemeKey;
const _localeKey = AppStrings.prefLocaleKey;

// Provider de SharedPreferences — se inyecta desde main.dart
final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Debe inyectarse en main.dart'),
);

// ─────────────────────────────────────────
// TEMA (light / dark / sistema)
// ─────────────────────────────────────────

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPrefsProvider);
    return _parseTheme(prefs.getString(_themeKey));
  }

  // Cambia el tema y lo persiste
  void changeTheme(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setString(_themeKey, mode.name);
  }

  // Convierte el string guardado a ThemeMode
  ThemeMode _parseTheme(String? value) {
    switch (value) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }
}

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

// ─────────────────────────────────────────
// IDIOMA (español / inglés)
// ─────────────────────────────────────────

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPrefsProvider);
    final saved = prefs.getString(_localeKey);
    if (saved == null) return null;
    return Locale(saved);
  }

  // Cambia el idioma y lo persiste
  void changeLocale(Locale locale) {
    state = locale;
    ref.read(sharedPrefsProvider).setString(_localeKey, locale.languageCode);
  }

  // Verifica si el usuario ya eligió un idioma antes
  static bool hasChosenLocale(SharedPreferences prefs) {
    return prefs.getString(_localeKey) != null;
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
