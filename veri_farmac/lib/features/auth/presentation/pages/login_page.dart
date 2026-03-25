import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState   = ref.watch(authProvider);
    final estaCargando = authState.estado == AuthEstado.cargando;

    ref.listen(authProvider, (_, actual) {
      if (actual.estaAutenticado) context.go(AppRoutes.dashboard);
      if (actual.estado == AuthEstado.error && actual.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(actual.error!)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.medication_rounded, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Inicia sesión para verificar\ntus medicamentos',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 48),
              GoogleSignInButton(
                estaCargando: estaCargando,
                alPresionar: () => ref.read(authProvider.notifier).signInWithGoogle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
