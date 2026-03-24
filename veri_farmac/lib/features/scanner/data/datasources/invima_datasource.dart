// Datasource de consulta al INVIMA (mock o real).

// Datasource que simula la consulta al INVIMA.
// Usa datos reales de medicamentos colombianos para el prototipo.
//
// ESTRATEGIA INVIMA:
// 1. Mock local (este archivo) — para desarrollo y demo del proyecto
// 2. Open Data: datos.gov.co tiene registros del INVIMA en CSV
//    que se pueden cargar en Supabase para consultas reales
// 3. Scraping controlado al portal del INVIMA (frágil, no recomendado)

class InvimaDataSource {
  // Base de datos mock con medicamentos reales del INVIMA
  static const _medicamentos = <String, Map<String, dynamic>>{
    // Clave: código de barras o registro sanitario
    '7702025010015': {
      'nombre': 'Acetaminofén 500 mg',
      'registro': 'INVIMA 2019M-0017142-R1',
      'laboratorio': 'Genfar S.A.',
      'titular': 'Genfar S.A.',
      'ingrediente': 'Acetaminofén',
      'concentracion': '500 mg',
      'forma': 'Tableta',
      'estado': 'vigente',
    },
    '7702004630016': {
      'nombre': 'Ibuprofeno 400 mg',
      'registro': 'INVIMA 2017M-0013456',
      'laboratorio': 'Tecnoquímicas S.A.',
      'titular': 'Tecnoquímicas S.A.',
      'ingrediente': 'Ibuprofeno',
      'concentracion': '400 mg',
      'forma': 'Tableta recubierta',
      'estado': 'vigente',
    },
    '7702025020014': {
      'nombre': 'Amoxicilina 500 mg',
      'registro': 'INVIMA 2015M-0008923-R2',
      'laboratorio': 'Genfar S.A.',
      'titular': 'Genfar S.A.',
      'ingrediente': 'Amoxicilina trihidrato',
      'concentracion': '500 mg',
      'forma': 'Cápsula',
      'estado': 'vencido',
    },
    '7702003100019': {
      'nombre': 'Loratadina 10 mg',
      'registro': 'INVIMA 2020M-0019845',
      'laboratorio': 'Procaps S.A.',
      'titular': 'Procaps S.A.',
      'ingrediente': 'Loratadina',
      'concentracion': '10 mg',
      'forma': 'Tableta',
      'estado': 'vigente',
    },
    '7702025030013': {
      'nombre': 'Metformina 850 mg',
      'registro': 'INVIMA 2018M-0015678',
      'laboratorio': 'Lafrancol S.A.',
      'titular': 'Lafrancol S.A.',
      'ingrediente': 'Metformina clorhidrato',
      'concentracion': '850 mg',
      'forma': 'Tableta',
      'estado': 'invalido',
    },
  };

  // Busca un medicamento por su código de barras
  Future<Map<String, dynamic>?> buscarPorBarcode(String barcode) async {
    // Simula el tiempo de respuesta de una API real
    await Future.delayed(const Duration(milliseconds: 600));
    return _medicamentos[barcode];
  }

  // Busca un medicamento por su registro sanitario INVIMA
  Future<Map<String, dynamic>?> buscarPorRegistro(String registro) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Busca en todos los medicamentos el que tenga ese registro
    for (final med in _medicamentos.values) {
      if (med['registro'].toString().contains(registro)) {
        return med;
      }
    }
    return null;
  }

  // Busca medicamentos por nombre o ingrediente activo
  Future<List<Map<String, dynamic>>> buscarPorTexto(String texto) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final query = texto.toLowerCase();
    return _medicamentos.values.where((med) {
      return med['nombre'].toString().toLowerCase().contains(query) ||
          med['ingrediente'].toString().toLowerCase().contains(query);
    }).toList();
  }
}
