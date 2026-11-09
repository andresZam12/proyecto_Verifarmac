import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/auth/data/models/app_user_model.dart';
import 'package:veri_farmac/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUserModel.fromSupabase', () {
    test('extrae nombre y avatar desde user_metadata', () {
      final model = AppUserModel.fromSupabase({
        'id': 'abc-123',
        'email': 'andres@example.com',
        'user_metadata': {
          'full_name': 'Andrés Zambrano',
          'avatar_url': 'https://example.com/avatar.png',
        },
      });

      expect(model.id, 'abc-123');
      expect(model.email, 'andres@example.com');
      expect(model.nombre, 'Andrés Zambrano');
      expect(model.avatarUrl, 'https://example.com/avatar.png');
      expect(model.farmaciaId, isNull);
    });

    test('no falla si user_metadata no existe', () {
      final model = AppUserModel.fromSupabase({
        'id': 'abc-123',
        'email': 'andres@example.com',
      });

      expect(model.nombre, isNull);
      expect(model.avatarUrl, isNull);
    });

    test('lee farmacia_id cuando está presente', () {
      final model = AppUserModel.fromSupabase({
        'id': 'abc-123',
        'email': 'farmacia@example.com',
        'farmacia_id': 'farmacia-99',
      });

      expect(model.farmaciaId, 'farmacia-99');
    });
  });

  group('AppUser equality', () {
    test('dos usuarios con el mismo id son iguales aunque difieran otros campos', () {
      const a = AppUser(id: '1', email: 'a@example.com', nombre: 'A');
      const b = AppUser(id: '1', email: 'b@example.com', nombre: 'B');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('usuarios con id distinto no son iguales', () {
      const a = AppUser(id: '1', email: 'a@example.com');
      const b = AppUser(id: '2', email: 'a@example.com');

      expect(a, isNot(equals(b)));
    });
  });
}
