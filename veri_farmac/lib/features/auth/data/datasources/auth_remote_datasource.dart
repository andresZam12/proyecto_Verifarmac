// Datasource de autenticación con Supabase Auth.
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

// Habla directamente con Supabase Auth.
// Solo el repositorio lo usa — nunca la UI.
class AuthRemoteDataSource {
  final _supabase = Supabase.instance.client;

  // Inicia sesión con Google usando OAuth de Supabase
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  // Cierra la sesión en Supabase
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Retorna el usuario actual o null si no hay sesión
  AppUser? get usuarioActual {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromSupabase(user.toJson());
  }

  // Stream que emite cada vez que cambia el estado de la sesión
  Stream<AppUser?> get cambiosDeAuth {
    return _supabase.auth.onAuthStateChange.map((evento) {
      final user = evento.session?.user;
      if (user == null) return null;
      return AppUserModel.fromSupabase(user.toJson());
    });
  }
}