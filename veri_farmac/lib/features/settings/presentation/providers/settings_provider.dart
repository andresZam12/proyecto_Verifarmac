// Re-exporta ThemeNotifier y LocaleNotifier para la pantalla de ajustes.
// TODO: exportar desde core/providers/theme_provider.dart

// Re-exporta los providers de tema e idioma del core.
// La pantalla de ajustes los consume desde aquí.
export '../../../../core/providers/theme_provider.dart'
    show themeNotifierProvider, localeNotifierProvider;