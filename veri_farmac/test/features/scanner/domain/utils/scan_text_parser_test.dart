import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/scanner/domain/utils/scan_text_parser.dart';

void main() {
  group('ScanTextParser.extractInvimaCode', () {
    test('extrae el código con guion normal', () {
      expect(
        ScanTextParser.extractInvimaCode('INVIMA 2008M-0007952 jarabe'),
        'INVIMA 2008M-0007952',
      );
    });

    test('extrae el código con espacio alrededor del guion (empaque real con OCR ruidoso)', () {
      // Caso real que motivó el fix de regex: "2008M- 007952"
      expect(
        ScanTextParser.extractInvimaCode('INVIMA 2008M- 007952'),
        isNotNull,
      );
    });

    test('es insensible a mayúsculas/minúsculas', () {
      expect(ScanTextParser.extractInvimaCode('invima 2020a-1234567'), isNotNull);
    });

    test('devuelve null si no hay ningún código INVIMA en el texto', () {
      expect(ScanTextParser.extractInvimaCode('Acetaminofén 500mg'), isNull);
    });
  });

  group('ScanTextParser.isEanBarcode', () {
    test('acepta códigos numéricos de 8 a 14 dígitos', () {
      expect(ScanTextParser.isEanBarcode('12345678'), isTrue);
      expect(ScanTextParser.isEanBarcode('7501234567890'), isTrue);
    });

    test('rechaza un registro INVIMA (no es un código de barras EAN)', () {
      expect(ScanTextParser.isEanBarcode('INVIMA 2008M-0007952'), isFalse);
    });

    test('rechaza números fuera de rango de longitud', () {
      expect(ScanTextParser.isEanBarcode('1234567'), isFalse); // 7 dígitos
      expect(ScanTextParser.isEanBarcode('123456789012345'), isFalse); // 15 dígitos
    });
  });

  group('ScanTextParser.extractExpiryDate', () {
    test('reconoce "VENCE: MM/YYYY"', () {
      final date = ScanTextParser.extractExpiryDate('VENCE: 07/2020');
      expect(date, DateTime(2020, 7, 31));
    });

    test('reconoce "EXP." con espacios alrededor del separador', () {
      final date = ScanTextParser.extractExpiryDate('EXP. 07 / 2020');
      expect(date, DateTime(2020, 7, 31));
    });

    test('reconoce "F.V.:" con año de 2 dígitos', () {
      final date = ScanTextParser.extractExpiryDate('F.V.: 07/20');
      expect(date, DateTime(2020, 7, 31));
    });

    test('devuelve null si no hay fecha de vencimiento en el texto', () {
      expect(ScanTextParser.extractExpiryDate('Acetaminofén 500mg'), isNull);
    });
  });

  group('ScanTextParser.parseExpiryString', () {
    test('interpreta "MM/YYYY" como devuelve el análisis de IA', () {
      expect(ScanTextParser.parseExpiryString('07/2020'), DateTime(2020, 7, 31));
    });

    test('devuelve null para "null" (string literal que a veces manda la IA)', () {
      expect(ScanTextParser.parseExpiryString('null'), isNull);
    });

    test('devuelve null para entrada vacía o null real', () {
      expect(ScanTextParser.parseExpiryString(''), isNull);
      expect(ScanTextParser.parseExpiryString(null), isNull);
    });
  });

  group('ScanTextParser.isExpired', () {
    final reference = DateTime(2026, 11, 4);

    test('una fecha pasada está vencida', () {
      expect(ScanTextParser.isExpired(DateTime(2020, 7, 31), now: reference), isTrue);
    });

    test('una fecha futura no está vencida', () {
      expect(ScanTextParser.isExpired(DateTime(2030, 1, 1), now: reference), isFalse);
    });

    test('sin fecha (null) no se considera vencido', () {
      expect(ScanTextParser.isExpired(null, now: reference), isFalse);
    });
  });
}
