// Estado de autenticación con Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// Estados posibles de la autenticación
enum AuthEstado { inicial, cargando, autenticado, noAutenticado, error }

class AuthState {
  const AuthState({
    this.estado = AuthEstado.inicial,
    this.usuario,
    this.error,
  });

  final AuthEstado estado;
  final AppUser?   usuario;
  final String?    error;

  bool get estaAutenticado => estado == AuthEstado.autenticado;
}

// Notifier que maneja el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signIn, this._signOut) : super(const AuthState());

  final SignInWithGoogleUseCase _signIn;
  final SignOutUseCase          _signOut;

  // Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signIn();
      state = const AuthState(estado: AuthEstado.autenticado);
    } catch (e) {
      state = AuthState(
        estado: AuthEstado.error,
        error: 'Error al iniciar sesión. Intenta de nuevo.',
      );
    }
  }

  // Cierra sesión
  Future<void> signOut() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signOut();
      state = const AuthState(estado: AuthEstado.noAutenticado);
    } catch (e) {
      state = AuthState(
        estado: AuthEstado.error,
        error: 'Error al cerrar sesión.',
      );
    }
  }
}

// Providers
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
