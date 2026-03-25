// Punto de entrada de la aplicación.
import 'package:flutter/material.dart';
import 'injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

// Punto de entrada de la app
void main() async {
  // Asegura que Flutter esté listo antes de inicializar servicios
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase (autenticación y base de datos en la nube)
  await Supabase.initialize(
    url: 'TU_SUPABASE_URL',       // reemplazar con tu URL de Supabase
    anonKey: 'TU_SUPABASE_ANON_KEY', // reemplazar con tu anon key
  );
  await configurarDependencias();
  
  // Carga las preferencias guardadas (tema e idioma)
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Inyectamos SharedPreferences para que los providers lo usen
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha cambios de tema e idioma en tiempo real
    final themeMode = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'VeriFarmac',
      debugShowCheckedModeBanner: false,

      // Tema claro y oscuro
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Idioma de la app
      locale: locale,
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navegación con go_router
      routerConfig: router,
    );
  }
}