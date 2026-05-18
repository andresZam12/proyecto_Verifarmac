import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../../../../core/constants/app_strings.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.localEmail,
    this.message,
  });
  final AuthStatus status;
  final AppUser?   user;
  final String?    error;
  final String?    localEmail;
  final String?    message;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

const _kValidCredentials = {
  'deividjulianalvarado@gmail.com': r'Deivid10812$',
  'giovannyzambrano@gmail.com':     '123456',
};

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signIn, this._signOut) : super(const AuthState());
  final SignInWithGoogleUseCase _signIn;
  final SignOutUseCase          _signOut;

  Future<void> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _signIn();
      state = const AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.error, error: AppStrings.errorSignIn);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || password.isEmpty) return;
    state = const AuthState(status: AuthStatus.loading);

    // Intentar Supabase primero (usuarios registrados con email/password)
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: trimmed,
        password: password,
      );
      state = const AuthState(status: AuthStatus.authenticated);
      return;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('not confirmed') || msg.contains('email not confirmed')) {
        state = const AuthState(
          status: AuthStatus.error,
          error:  'Debes confirmar tu correo antes de iniciar sesión. '
                  'Revisa tu bandeja de entrada (y la carpeta de spam).',
        );
        return;
      }
      // Otro error → probar credenciales hardcodeadas de prueba
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final expected = _kValidCredentials[trimmed];
    if (expected != null && expected == password) {
      state = AuthState(status: AuthStatus.authenticated, localEmail: trimmed);
    } else {
      state = const AuthState(
        status: AuthStatus.error,
        error:  'Correo o contraseña incorrectos.',
      );
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );

      if (response.session != null) {
        // Proyecto con confirmación deshabilitada → sesión inmediata
        state = const AuthState(status: AuthStatus.authenticated);
      } else if (response.user != null) {
        // Cuenta creada, esperando confirmación de email
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          message: '¡Registrado con éxito! Inicia sesión.',
        );
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          error: 'No se pudo crear la cuenta. Intenta de nuevo.',
        );
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit') ||
          msg.contains('email rate') || msg.contains('rate_limit')) {
        // La cuenta pudo haberse creado aunque el correo no se enviara.
        // Intentar iniciar sesión directamente.
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );
          state = const AuthState(status: AuthStatus.authenticated);
          return;
        } catch (_) {}
        state = const AuthState(
          status: AuthStatus.error,
          error: 'Se alcanzó el límite de correos de verificación. '
                 'Espera unos minutos e intenta de nuevo.',
        );
        return;
      }

      final error = msg.contains('already registered') || msg.contains('already')
          ? 'Este correo ya está registrado. Intenta iniciar sesión.'
          : msg.contains('password')
              ? 'La contraseña debe tener al menos 6 caracteres.'
              : msg.contains('valid') || msg.contains('invalid')
                  ? 'El correo no es válido.'
                  : msg.contains('signup') || msg.contains('disabled')
                      ? 'El registro no está habilitado en este momento.'
                      : 'Error al registrarse. Intenta de nuevo.';
      state = AuthState(status: AuthStatus.error, error: error);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error:  'Error al registrarse. Intenta de nuevo.',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.verifarmac://reset-callback',
      );
    } catch (_) {}
  }

  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.error, error: AppStrings.errorSignOut);
    }
  }
}

final _dataSourceProvider = Provider((_) => AuthRemoteDataSource());
final _repositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(_dataSourceProvider)),
);
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    SignInWithGoogleUseCase(ref.read(_repositoryProvider)),
    SignOutUseCase(ref.read(_repositoryProvider)),
  ),
);
