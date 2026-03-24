// Maneja ThemeMode (light / dark / system) con Riverpod.
// TODO: implementar ThemeNotifier y LocaleNotifier con SharedPreferences

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Claves para guardar en SharedPreferences
const _temaKey = 'app_tema';
const _idiomaKey = 'app_idioma';

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
    // Lee el tema guardado, si no hay ninguno usa el del sistema
    final prefs = ref.read(sharedPrefsProvider);
    final guardado = prefs.getString(_temaKey);
    return _parsearTema(guardado);
  }

  // Cambia el tema y lo guarda
  void cambiarTema(ThemeMode modo) {
    state = modo;
    ref.read(sharedPrefsProvider).setString(_temaKey, modo.name);
  }

  // Convierte el string guardado a ThemeMode
  ThemeMode _parsearTema(String? valor) {
    switch (valor) {
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
    // Lee el idioma guardado, null significa que sigue el sistema
    final prefs = ref.read(sharedPrefsProvider);
    final guardado = prefs.getString(_idiomaKey);
    if (guardado == null) return null;
    return Locale(guardado);
  }

  // Cambia el idioma y lo guarda
  void cambiarIdioma(Locale locale) {
    state = locale;
    ref.read(sharedPrefsProvider).setString(_idiomaKey, locale.languageCode);
  }

  // Verifica si el usuario ya eligió un idioma antes
  static bool yaEligioIdioma(SharedPreferences prefs) {
    return prefs.getString(_idiomaKey) != null;
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);