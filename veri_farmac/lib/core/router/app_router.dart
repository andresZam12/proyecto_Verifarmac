// Navegación central con go_router.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/settings/presentation/pages/language_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/medicine_detail/presentation/pages/medicine_detail_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/scanner/domain/entities/scan_result.dart';

// ─────────────────────────────────────────
// RUTAS — constantes para evitar errores de tipeo
// ─────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const splash   = '/';
  static const login    = '/login';
  static const dashboard = '/dashboard';
  static const scanner  = '/scanner';
  static const history  = '/history';
  static const settings = '/settings';
  static const medicine = '/medicine';
  static const map      = '/map';
  // Sub-rutas de settings
  static const settingsProfile  = '/settings/profile';
  static const settingsTheme    = '/settings/theme';
  static const settingsLanguage = '/settings/language';
}

// ─────────────────────────────────────────
// ROUTER
// ─────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    // Redirige al login si no hay sesión activa
    redirect: (context, state) {
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      final currentPath = state.matchedLocation;

      // Rutas que no requieren sesión
      const publicRoutes = [AppRoutes.splash, AppRoutes.login];
      final isPublic = publicRoutes.contains(currentPath);

      if (!hasSession && !isPublic) return AppRoutes.login;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
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
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: AppRoutes.medicine,
        builder: (context, state) {
          final result = state.extra as ScanResult;
          return MedicineDetailPage(scanResult: result);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguagePage(),
          ),
        ],
      ),
    ],
  );
});
