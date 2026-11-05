import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/scanner/data/models/scan_result_model.dart';
import 'package:veri_farmac/features/scanner/domain/entities/scan_result.dart';

void main() {
  final scannedAt = DateTime(2026, 11, 4, 10, 30);

  test('toJson usa las claves en español esperadas y method.name para el método', () {
    final result = ScanResultModel(
      id: 'r-1',
      scannedValue: 'INVIMA 2008M-0007952',
      method: ScanMethod.visual,
      scannedAt: scannedAt,
      confidence: 0.85,
      medicineName: 'Dihidrocodeína',
      sanitaryRecord: 'INVIMA 2008M-0007952',
      status: 'vencido',
      error: 'observación de la IA',
    );

    final json = result.toJson();

    expect(json['id'], 'r-1');
    expect(json['valor_escaneado'], 'INVIMA 2008M-0007952');
    expect(json['metodo'], 'visual');
    expect(json['escaneado_en'], scannedAt.toIso8601String());
    expect(json['confianza'], 0.85);
    expect(json['nombre_medicamento'], 'Dihidrocodeína');
    expect(json['registro_sanitario'], 'INVIMA 2008M-0007952');
    expect(json['estado'], 'vencido');
    expect(json['error'], 'observación de la IA');
  });

  test('fromJson reconstruye el mismo objeto a partir de toJson (round-trip) para cada método', () {
    for (final method in ScanMethod.values) {
      final original = ScanResultModel(
        id: 'r-${method.name}',
        scannedValue: 'valor-${method.name}',
        method: method,
        scannedAt: scannedAt,
        confidence: 0.5,
        medicineName: 'Medicamento X',
        sanitaryRecord: 'INVIMA 2020M-0000001',
        status: 'vigente',
      );

      final roundTripped = ScanResultModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.scannedValue, original.scannedValue);
      expect(roundTripped.method, method, reason: 'debe reconocer "${method.name}" de vuelta');
      expect(roundTripped.scannedAt, original.scannedAt);
      expect(roundTripped.confidence, original.confidence);
      expect(roundTripped.medicineName, original.medicineName);
      expect(roundTripped.sanitaryRecord, original.sanitaryRecord);
      expect(roundTripped.status, original.status);
    }
  });

  test('un método desconocido en el JSON cae por defecto en ScanMethod.barcode', () {
    final json = {
      'id': 'r-x',
      'valor_escaneado': '123',
      'metodo': 'algo-que-no-existe',
      'escaneado_en': scannedAt.toIso8601String(),
    };

    expect(ScanResultModel.fromJson(json).method, ScanMethod.barcode);
  });

  test('isSuccessful es true solo cuando hay nombre de medicamento y no hay error', () {
    final success = ScanResultModel(
      id: 'ok',
      scannedValue: 'x',
      method: ScanMethod.ocr,
      scannedAt: scannedAt,
      medicineName: 'Acetaminofén',
    );
    final failure = ScanResultModel(
      id: 'fail',
      scannedValue: 'x',
      method: ScanMethod.ocr,
      scannedAt: scannedAt,
      error: 'no encontrado',
    );

    expect(success.isSuccessful, isTrue);
    expect(failure.isSuccessful, isFalse);
  });
}
