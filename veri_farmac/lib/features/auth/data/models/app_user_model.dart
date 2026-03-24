// Modelo de usuario con serialización JSON.
import '../../domain/entities/app_user.dart';

// Extiende AppUser y agrega la conversión desde/hacia JSON de Supabase.
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    super.nombre,
    super.avatarUrl,
    super.farmaciaId,
  });

  // Crea un AppUserModel desde los datos del usuario de Supabase
  factory AppUserModel.fromSupabase(Map<String, dynamic> json) {
    return AppUserModel(
      id:         json['id'] as String,
      email:      json['email'] as String,
      nombre:     json['user_metadata']?['full_name'] as String?,
      avatarUrl:  json['user_metadata']?['avatar_url'] as String?,
      farmaciaId: json['farmacia_id'] as String?,
    );
  }
}