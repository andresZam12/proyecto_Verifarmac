// Mock con medicamentos reales del INVIMA para desarrollo y demo.
// Fuente: consulta manual al portal invima.gov.co
//
// Para producción: reemplazar con datos reales del CSV disponible en:
// https://www.datos.gov.co → buscar "INVIMA registros sanitarios"

import '../models/medicine_model.dart';

class InvimaMockDataSource {
  // Datos indexados por código de barras para búsqueda rápida
  static const _data = <String, Map<String, dynamic>>{
    '7702025010015': {
      'nombre':        'Acetaminofén 500 mg',
      'registro':      'INVIMA 2019M-0017142-R1',
      'laboratorio':   'Genfar S.A.',
      'titular':       'Genfar S.A.',
      'ingrediente':   'Acetaminofén',
      'concentracion': '500 mg',
      'forma':         'Tableta',
      'estado':        'vigente',
    },
    '7702004630016': {
      'nombre':        'Ibuprofeno 400 mg',
      'registro':      'INVIMA 2017M-0013456',
      'laboratorio':   'Tecnoquímicas S.A.',
      'titular':       'Tecnoquímicas S.A.',
      'ingrediente':   'Ibuprofeno',
      'concentracion': '400 mg',
      'forma':         'Tableta recubierta',
      'estado':        'vigente',
    },
    '7702025020014': {
      'nombre':        'Amoxicilina 500 mg',
      'registro':      'INVIMA 2015M-0008923-R2',
      'laboratorio':   'Genfar S.A.',
      'titular':       'Genfar S.A.',
      'ingrediente':   'Amoxicilina trihidrato',
      'concentracion': '500 mg',
      'forma':         'Cápsula',
      'estado':        'vencido',
    },
    '7702003100019': {
      'nombre':        'Loratadina 10 mg',
      'registro':      'INVIMA 2020M-0019845',
      'laboratorio':   'Procaps S.A.',
      'titular':       'Procaps S.A.',
      'ingrediente':   'Loratadina',
      'concentracion': '10 mg',
      'forma':         'Tableta',
      'estado':        'vigente',
    },
    '7702025030013': {
      'nombre':        'Metformina 850 mg',
      'registro':      'INVIMA 2018M-0015678',
      'laboratorio':   'Lafrancol S.A.',
      'titular':       'Lafrancol S.A.',
      'ingrediente':   'Metformina clorhidrato',
      'concentracion': '850 mg',
      'forma':         'Tableta',
      'estado':        'invalido',
    },
    '7702001234567': {
      'nombre':        'Atorvastatina 20 mg',
      'registro':      'INVIMA 2021M-0021456',
      'laboratorio':   'MK S.A.',
      'titular':       'MK S.A.',
      'ingrediente':   'Atorvastatina cálcica',
      'concentracion': '20 mg',
      'forma':         'Tableta recubierta',
      'estado':        'vigente',
    },
  };

  // Busca por código de barras
  Future<MedicineModel?> findByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = _data[barcode];
    if (data == null) return null;
    return MedicineModel.fromJson({...data, 'id': barcode});
  }

  // Busca por registro sanitario INVIMA
  Future<MedicineModel?> findByRegistry(String registry) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (final entry in _data.entries) {
      if (entry.value['registro'].toString().contains(registry)) {
        return MedicineModel.fromJson({...entry.value, 'id': entry.key});
      }
    }
    return null;
  }

  // Busca por nombre o ingrediente activo
  Future<List<MedicineModel>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return _data.entries
        .where((e) =>
            e.value['nombre'].toString().toLowerCase().contains(q) ||
            e.value['ingrediente'].toString().toLowerCase().contains(q))
        .map((e) => MedicineModel.fromJson({...e.value, 'id': e.key}))
        .toList();
  }
}
