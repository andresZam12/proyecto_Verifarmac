// Implementación del repositorio de auth.
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// Implementa IAuthRepository usando el datasource de Supabase.
// Captura excepciones y las convierte en errores manejables.
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signInWithGoogle();
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  AppUser? get usuarioActual => _dataSource.usuarioActual;

  @override
  Stream<AppUser?> get cambiosDeAuth => _dataSource.cambiosDeAuth;
}