import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final _supabase = Supabase.instance.client;

Future<void> signInWithGoogle() async {
  await _supabase.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'io.supabase.verifarmac://login-callback',
  );
}

  Future<void> signOut() async => await _supabase.auth.signOut();

  AppUser? get usuarioActual {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromSupabase(user.toJson());
  }

  Stream<AppUser?> get cambiosDeAuth {
    return _supabase.auth.onAuthStateChange.map((evento) {
      final user = evento.session?.user;
      if (user == null) return null;
      return AppUserModel.fromSupabase(user.toJson());
    });
  }
}
