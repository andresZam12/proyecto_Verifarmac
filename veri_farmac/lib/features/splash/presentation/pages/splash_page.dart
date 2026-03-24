// Pantalla de splash con animación.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Espera 2 segundos y luego decide a dónde navegar
    Future.delayed(const Duration(seconds: 2), _navegar);
  }

  void _navegar() {
    if (!mounted) return;

    final prefs = ref.read(sharedPrefsProvider);
    final haySession = Supabase.instance.client.auth.currentSession != null;
    final yaEligioIdioma = LocaleNotifier.yaEligioIdioma(prefs);

    if (!yaEligioIdioma) {
      // Primera vez — va a elegir idioma
      context.go(AppRoutes.idioma);
    } else if (haySession) {
      // Ya tiene sesión activa — va al dashboard
      context.go(AppRoutes.dashboard);
    } else {
      // Sin sesión — va al login
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.medication_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Nombre de la app
            const Text(
              'VeriFarmac',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Slogan
            Text(
              'Verifica tus medicamentos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white.withOpacity(0.75),
              ),
            ),

            const SizedBox(height: 60),

            // Indicador de carga
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}