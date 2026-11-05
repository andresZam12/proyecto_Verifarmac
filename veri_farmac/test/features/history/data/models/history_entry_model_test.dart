import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/history/data/models/history_entry_model.dart';

void main() {
  final createdAt = DateTime(2026, 11, 4, 10, 30);

  test('toJson produce las claves en español que espera Supabase/SharedPreferences', () {
    final entry = HistoryEntryModel(
      id: 'abc-123',
      medicineName: 'Dihidrocodeína Bitartrato Jarabe',
      sanitaryRecord: 'INVIMA 2008M-0007952',
      status: 'vencido',
      method: 'visual',
      createdAt: createdAt,
      laboratory: 'Bausch Health',
      confidence: 0.85,
      synced: false,
    );

    final json = entry.toJson();

    expect(json['id'], 'abc-123');
    expect(json['nombre_medicamento'], 'Dihidrocodeína Bitartrato Jarabe');
    expect(json['registro_sanitario'], 'INVIMA 2008M-0007952');
    expect(json['estado'], 'vencido');
    expect(json['metodo'], 'visual');
    expect(json['creado_en'], createdAt.toIso8601String());
    expect(json['laboratorio'], 'Bausch Health');
    expect(json['confianza'], 0.85);
    expect(json['sincronizado'], false);
  });

  test('fromJson reconstruye el mismo objeto a partir de toJson (round-trip)', () {
    final original = HistoryEntryModel(
      id: 'xyz-789',
      medicineName: 'Acetaminofén',
      sanitaryRecord: 'INVIMA 2015M-0012345',
      status: 'vigente',
      method: 'ocr',
      createdAt: createdAt,
      laboratory: 'Genfar',
      confidence: 0.9,
      synced: true,
    );

    final roundTripped = HistoryEntryModel.fromJson(original.toJson());

    expect(roundTripped.id, original.id);
    expect(roundTripped.medicineName, original.medicineName);
    expect(roundTripped.sanitaryRecord, original.sanitaryRecord);
    expect(roundTripped.status, original.status);
    expect(roundTripped.method, original.method);
    expect(roundTripped.createdAt, original.createdAt);
    expect(roundTripped.laboratory, original.laboratory);
    expect(roundTripped.confidence, original.confidence);
    expect(roundTripped.synced, original.synced);
  });

  test('fromJson usa confianza=0.0 y sincronizado=false cuando faltan en el JSON', () {
    final json = {
      'id': 'id-1',
      'nombre_medicamento': 'X',
      'registro_sanitario': 'Y',
      'estado': 'no_encontrado',
      'metodo': 'ocr',
      'creado_en': createdAt.toIso8601String(),
    };

    final model = HistoryEntryModel.fromJson(json);

    expect(model.confidence, 0.0);
    expect(model.synced, false);
    expect(model.laboratory, isNull);
  });
}
