// Entidad de usuario — Dart puro, sin dependencias externas.

// Entidad de usuario — Dart puro, sin dependencias externas.
// Representa al usuario autenticado en toda la app.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.nombre,
    this.avatarUrl,
    this.farmaciaId,
  });

  final String id;
  final String email;
  final String? nombre;       // nombre del usuario
  final String? avatarUrl;    // foto de perfil de Google
  final String? farmaciaId;   // farmacia a la que pertenece

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}