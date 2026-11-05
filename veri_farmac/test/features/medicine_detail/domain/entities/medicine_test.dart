import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/medicine_detail/domain/entities/medicine.dart';

void main() {
  group('Medicine.parseCondition', () {
    test('mapea "vigente" a MedicineCondition.valid', () {
      expect(Medicine.parseCondition('vigente'), MedicineCondition.valid);
    });

    test('mapea "vencido" a MedicineCondition.expired', () {
      expect(Medicine.parseCondition('vencido'), MedicineCondition.expired);
    });

    test('mapea "invalido" a MedicineCondition.invalid', () {
      expect(Medicine.parseCondition('invalido'), MedicineCondition.invalid);
    });

    test('mapea "sospechoso" a MedicineCondition.suspicious', () {
      expect(Medicine.parseCondition('sospechoso'), MedicineCondition.suspicious);
    });

    test('cualquier otro valor cae en MedicineCondition.unknown', () {
      expect(Medicine.parseCondition('algo-inesperado'), MedicineCondition.unknown);
    });

    test('es insensible a mayúsculas/minúsculas', () {
      expect(Medicine.parseCondition('VIGENTE'), MedicineCondition.valid);
    });
  });

  group('MedicineConditionX', () {
    test('solo "valid" se considera seguro (isSafe)', () {
      expect(MedicineCondition.valid.isSafe, isTrue);
      expect(MedicineCondition.expired.isSafe, isFalse);
      expect(MedicineCondition.invalid.isSafe, isFalse);
      expect(MedicineCondition.suspicious.isSafe, isFalse);
      expect(MedicineCondition.unknown.isSafe, isFalse);
    });

    test('cada condición tiene una etiqueta en español', () {
      expect(MedicineCondition.valid.label, 'Vigente');
      expect(MedicineCondition.expired.label, 'Vencido');
      expect(MedicineCondition.invalid.label, 'Inválido');
      expect(MedicineCondition.suspicious.label, 'Sospechoso');
      expect(MedicineCondition.unknown.label, 'Desconocido');
    });
  });
}
