import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

enum AuthEstado { inicial, cargando, autenticado, noAutenticado, error }

class AuthState {
  const AuthState({this.estado = AuthEstado.inicial, this.usuario, this.error});
  final AuthEstado estado;
  final AppUser?   usuario;
  final String?    error;
  bool get estaAutenticado => estado == AuthEstado.autenticado;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signIn, this._signOut) : super(const AuthState());
  final SignInWithGoogleUseCase _signIn;
  final SignOutUseCase          _signOut;

  Future<void> signInWithGoogle() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signIn();
      state = const AuthState(estado: AuthEstado.autenticado);
    } catch (e) {
      state = const AuthState(estado: AuthEstado.error, error: 'Error al iniciar sesión.');
    }
  }

  Future<void> signOut() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signOut();
      state = const AuthState(estado: AuthEstado.noAutenticado);
    } catch (e) {
      state = const AuthState(estado: AuthEstado.error, error: 'Error al cerrar sesión.');
    }
  }
}

final _dataSourceProvider = Provider((_) => AuthRemoteDataSource());
final _repositoryProvider = Provider((ref) => AuthRepositoryImpl(ref.read(_dataSourceProvider)));
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    SignInWithGoogleUseCase(ref.read(_repositoryProvider)),
    SignOutUseCase(ref.read(_repositoryProvider)),
  ),
);
