// Caso de uso: cerrar sesión.
 
import '../repositories/i_auth_repository.dart';

// Caso de uso: cerrar sesión.
class SignOutUseCase {
  const SignOutUseCase(this._repo);
  final IAuthRepository _repo;

  Future<void> call() => _repo.signOut();
}
