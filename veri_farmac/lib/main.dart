// Punto de entrada de la aplicación.
import 'package:flutter/material.dart';
import 'injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Asegura que Flutter esté listo antes de inicializar servicios
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase (autenticación y base de datos en la nube)
  await Supabase.initialize(
    url: 'https://ysmrqovkymjtxboybgpx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzbXJxb3ZreW1qdHhib3liZ3B4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MTIyOTksImV4cCI6MjA4OTk4ODI5OX0.ODXyHcF4Vo98yYQ_swZOqVrk-W-gOy1680QNg9fRARE',
    authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  await setupDependencies();

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
    final locale    = ref.watch(localeNotifierProvider);
    final router    = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'VeriFarmac',
      debugShowCheckedModeBanner: false,

      // Tema claro y oscuro
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Idioma de la app — el locale viene del LocaleNotifier (SharedPreferences)
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Navegación con go_router
      routerConfig: router,
    );
  }
}
