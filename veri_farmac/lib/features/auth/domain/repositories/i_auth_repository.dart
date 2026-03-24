// Contrato del repositorio de autenticación.

import '../entities/app_user.dart';

// Contrato que define qué puede hacer el repositorio de auth.
// La capa de datos lo implementa, el dominio solo conoce esta interfaz.
abstract class IAuthRepository {
  // Inicia sesión con Google
  Future<void> signInWithGoogle();

  // Cierra la sesión actual
  Future<void> signOut();

  // Usuario actualmente autenticado (null si no hay sesión)
  AppUser? get usuarioActual;

  // Stream que emite cambios en la sesión
  Stream<AppUser?> get cambiosDeAuth;
}
