import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/medicine_detail/data/utils/invima_status_parser.dart';

void main() {
  group('InvimaStatusParser.normalizeStatus', () {
    test('reconoce "vigente"', () {
      expect(InvimaStatusParser.normalizeStatus('Vigente'), 'vigente');
    });

    test('reconoce "vencido"', () {
      expect(InvimaStatusParser.normalizeStatus('Vencido'), 'vencido');
    });

    test('reconoce "suspendido" como inválido', () {
      expect(InvimaStatusParser.normalizeStatus('Suspendido'), 'invalido');
    });

    test('reconoce "cancelado/inválido" como inválido', () {
      expect(InvimaStatusParser.normalizeStatus('Invalidado'), 'invalido');
    });

    test('reconoce "sospechoso"', () {
      expect(InvimaStatusParser.normalizeStatus('Sospechoso'), 'sospechoso');
    });

    test('un estado desconocido cae en "desconocido"', () {
      expect(InvimaStatusParser.normalizeStatus('Estado Raro XYZ'), 'desconocido');
    });

    test('es insensible a mayúsculas/minúsculas', () {
      expect(InvimaStatusParser.normalizeStatus('VIGENTE'), 'vigente');
    });
  });

  group('InvimaStatusParser.escape', () {
    test('escapa comillas simples para evitar romper la consulta SoQL', () {
      expect(InvimaStatusParser.escape("O'Brien"), "O''Brien");
    });

    test('no modifica un texto sin comillas', () {
      expect(InvimaStatusParser.escape('Acetaminofen'), 'Acetaminofen');
    });
  });
}
