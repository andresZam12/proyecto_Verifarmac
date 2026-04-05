import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../../../../core/constants/app_strings.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({this.status = AuthStatus.initial, this.user, this.error});
  final AuthStatus status;
  final AppUser?   user;
  final String?    error;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

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
