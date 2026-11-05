import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/medicine_detail/data/models/medicine_model.dart';
import 'package:veri_farmac/features/medicine_detail/domain/entities/medicine.dart';

void main() {
  test('fromJson interpreta el estado con Medicine.parseCondition', () {
    final json = {
      'id': 'exp-1',
      'nombre': 'Dihidrocodeína Bitartrato Jarabe',
      'registro': 'INVIMA 2008M-0007952',
      'laboratorio': 'Bausch Health',
      'estado': 'vigente',
      'titular': 'Bausch Health S.A.',
      'ingrediente': 'Dihidrocodeína',
      'concentracion': '2.42 mg/mL',
      'forma': 'Solución oral',
    };

    final medicine = MedicineModel.fromJson(json);

    expect(medicine.id, 'exp-1');
    expect(medicine.name, 'Dihidrocodeína Bitartrato Jarabe');
    expect(medicine.sanitaryRecord, 'INVIMA 2008M-0007952');
    expect(medicine.laboratory, 'Bausch Health');
    expect(medicine.condition, MedicineCondition.valid);
    expect(medicine.holder, 'Bausch Health S.A.');
    expect(medicine.activeIngredient, 'Dihidrocodeína');
    expect(medicine.concentration, '2.42 mg/mL');
    expect(medicine.pharmaceuticalForm, 'Solución oral');
  });

  test('fromJson usa el registro como id cuando no viene un id explícito', () {
    final json = {
      'nombre': 'X',
      'registro': 'INVIMA 2020M-0000001',
      'laboratorio': 'Lab',
      'estado': 'vigente',
    };

    expect(MedicineModel.fromJson(json).id, 'INVIMA 2020M-0000001');
  });

  test('toJson no incluye "id" — solo se reconstruye a partir del registro en fromJson', () {
    // Esto es intencional en el modelo actual: toJson() es para guardar en
    // Supabase (donde el id de fila es independiente), no para un
    // round-trip perfecto. Si fromJson(toJson(m)) se usa como "copy", el
    // id original se pierde a menos que coincida con sanitaryRecord.
    const medicine = MedicineModel(
      id: 'id-interno-distinto-del-registro',
      name: 'X',
      sanitaryRecord: 'INVIMA 2020M-0000001',
      laboratory: 'Lab',
      condition: MedicineCondition.valid,
    );

    final json = medicine.toJson();
    expect(json.containsKey('id'), isFalse);

    final roundTripped = MedicineModel.fromJson(json);
    expect(roundTripped.id, 'INVIMA 2020M-0000001'); // no es "id-interno-distinto-del-registro"
  });

  test('toJson serializa la condición usando el nombre del enum', () {
    const medicine = MedicineModel(
      id: 'x',
      name: 'X',
      sanitaryRecord: 'Y',
      laboratory: 'Z',
      condition: MedicineCondition.expired,
    );

    expect(medicine.toJson()['estado'], 'expired');
  });
}
