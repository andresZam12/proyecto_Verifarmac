// Navegación central con go_router.
// TODO: definir todas las rutas y el redirect de autenticación

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importamos las páginas (aún vacías, se llenarán después)
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/settings/presentation/pages/language_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/medicine_detail/presentation/pages/medicine_detail_page.dart';
import '../../features/map/presentation/pages/map_page.dart';

// ─────────────────────────────────────────
// RUTAS — constantes para evitar errores de tipeo
// ─────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const splash          = '/';
  static const idioma          = '/idioma';
  static const login           = '/login';
  static const dashboard       = '/dashboard';
  static const scanner         = '/scanner';
  static const historial       = '/historial';
  static const ajustes         = '/ajustes';
  static const medicamento     = '/medicamento';
  static const mapa            = '/mapa';
}

// ─────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    // Redirige al login si no hay sesión activa
    redirect: (context, state) {
      final sesionActiva = Supabase.instance.client.auth.currentSession != null;
      final rutaActual = state.matchedLocation;

      // Rutas que no requieren sesión
      final rutasPublicas = [
        AppRoutes.splash,
        AppRoutes.idioma,
        AppRoutes.login,
      ];

      final esPublica = rutasPublicas.contains(rutaActual);

      // Si no hay sesión y la ruta es privada, va al login
      if (!sesionActiva && !esPublica) return AppRoutes.login;

      return null; // sin redirección
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.idioma,
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.scanner,
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.historial,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.mapa,
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: AppRoutes.medicamento,
        builder: (context, state) {
          // Recibe el id del medicamento como parámetro extra
          final id = state.extra as String? ?? '';
          return MedicineDetailPage(medicineId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.ajustes,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});