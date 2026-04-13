// Datasource que consulta la API pública del INVIMA en datos.gov.co
//
// FUENTE OFICIAL:
// El gobierno colombiano publica los registros sanitarios del INVIMA en:
// https://www.datos.gov.co/Salud-y-Protecci-n-Social/INVIMA-Registros-Sanitarios-Vigentes-Medicamentos-/5h2e-6hhg
//
// API Socrata (SODA) — formato de consulta:
// GET https://www.datos.gov.co/resource/5h2e-6hhg.json?$where=<SoQL>&$limit=5
//
// Para activar esta fuente en lugar del mock:
// En medicine_provider.dart, reemplazar InvimaMockDataSource por InvimaApiDataSource
// y cambiar los métodos (findByBarcode → findByName / findByRegistry).

import 'package:dio/dio.dart';
import '../models/medicine_model.dart';

class InvimaApiDataSource {
  InvimaApiDataSource() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://www.datos.gov.co/resource/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
  }

  late final Dio _dio;

  // Dataset ID del INVIMA en datos.gov.co
  // Fuente: "Registros Sanitarios Vigentes de Medicamentos"
  static const _dataset = '5h2e-6hhg.json';
  static const _limit   = 5;

  // Busca por nombre de producto (búsqueda aproximada, sin código de barras en el dataset)
  Future<MedicineModel?> findByName(String name) async {
    try {
      final response = await _dio.get(_dataset, queryParameters: {
        r'$where': "upper(nombre_producto) like upper('%${_escape(name)}%')",
        r'$limit': '$_limit',
      });
      final list = response.data as List<dynamic>;
      if (list.isEmpty) { return null; }
      return _fromSocrata(list.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Busca por número de expediente o registro sanitario
  Future<MedicineModel?> findByRegistry(String registry) async {
    // Elimina el prefijo "INVIMA " si viene incluido
    final clean = registry
        .replaceAll(RegExp(r'^INVIMA\s*', caseSensitive: false), '');
    try {
      final response = await _dio.get(_dataset, queryParameters: {
        r'$where': "expediente like '%${_escape(clean)}%'",
        r'$limit': '$_limit',
      });
      final list = response.data as List<dynamic>;
      if (list.isEmpty) { return null; }
      return _fromSocrata(list.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Búsqueda múltiple por nombre para listar resultados
  Future<List<MedicineModel>> search(String query) async {
    try {
      final response = await _dio.get(_dataset, queryParameters: {
        r'$where': "upper(nombre_producto) like upper('%${_escape(query)}%')",
        r'$limit': '$_limit',
      });
      final list = response.data as List<dynamic>;
      return list
          .map((item) => _fromSocrata(item as Map<String, dynamic>))
          .whereType<MedicineModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Mapea la respuesta de la API Socrata al modelo interno.
  // Campos del dataset datos.gov.co:
  //   expediente, nombre_producto, titular, laboratorio,
  //   principio_activo, concentracion, forma_farmaceutica, estado
  MedicineModel? _fromSocrata(Map<String, dynamic> json) {
    try {
      final rawStatus = (json['estado'] as String? ?? '').toLowerCase();
      return MedicineModel.fromJson({
        'id':            json['expediente'] ?? '',
        'nombre':        json['nombre_producto'] ?? 'Sin nombre',
        'registro':      'INVIMA ${json['expediente'] ?? ''}',
        'laboratorio':   json['laboratorio'] ?? 'Desconocido',
        'titular':       json['titular'],
        'ingrediente':   json['principio_activo'],
        'concentracion': json['concentracion'],
        'forma':         json['forma_farmaceutica'],
        'estado':        _normalizeStatus(rawStatus),
      });
    } catch (_) {
      return null;
    }
  }

  // Convierte el estado devuelto por la API a los valores internos del dominio
  String _normalizeStatus(String raw) {
    if (raw.contains('vigente'))   { return 'vigente'; }
    if (raw.contains('venc'))      { return 'vencido'; }
    if (raw.contains('invalid') || raw.contains('suspendido')) {
      return 'invalido';
    }
    if (raw.contains('sospech'))   { return 'sospechoso'; }
    return 'desconocido';
  }

  // Escapa comillas simples para consultas SoQL
  String _escape(String value) => value.replaceAll("'", "''");
}
