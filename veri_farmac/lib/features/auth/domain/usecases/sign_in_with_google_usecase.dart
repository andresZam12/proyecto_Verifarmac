// Caso de uso: iniciar sesión con Google.

import '../repositories/i_auth_repository.dart';

// Caso de uso: iniciar sesión con Google.
// La UI llama a este use case — nunca al repositorio directamente.
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repo);
  final IAuthRepository _repo;

  Future<void> call() => _repo.signInWithGoogle();
}
