// Datasource de consulta al INVIMA — Dart puro, sin dependencias externas.
// Usa el mock con los datos hardcodeados para pruebas.
// Para la API real, ver invima_api_datasource.dart

class InvimaDataSource {
  // Base de datos mock con medicamentos reales del INVIMA
  static const _medicines = <String, Map<String, dynamic>>{
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
  };

  // Busca un medicamento por código de barras
  Future<Map<String, dynamic>?> findByBarcode(String barcode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _medicines[barcode];
  }

  // Busca un medicamento por registro sanitario
  Future<Map<String, dynamic>?> findByRegistry(String registry) async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (final med in _medicines.values) {
      if (med['registro'].toString().contains(registry)) {
        return med;
      }
    }
    return null;
  }

  // Busca medicamentos por nombre o ingrediente activo
  Future<List<Map<String, dynamic>>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return _medicines.values.where((med) {
      return med['nombre'].toString().toLowerCase().contains(q) ||
          med['ingrediente'].toString().toLowerCase().contains(q);
    }).toList();
  }
}
