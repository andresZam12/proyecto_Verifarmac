// Datasource que consulta la API pública del INVIMA en datos.gov.co
//
// FUENTE OFICIAL (dataset actualizado):
// https://www.datos.gov.co/d/i7cb-raxc
// "CÓDIGO ÚNICO DE MEDICAMENTOS VIGENTES"
//
// Campos relevantes:
//   registrosanitario → "INVIMA 2008M-0007952"
//   producto          → nombre del medicamento
//   principioactivo   → ingrediente activo
//   titular           → empresa titular del registro
//   nombrerol         → fabricante (cuando tiporol = FABRICANTE)
//   estadoregistro    → "Vigente", "Vencido", "Suspendido", etc.
//   formafarmaceutica → tableta, jarabe, etc.
//   cantidad + unidadmedida → concentración

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';
import '../utils/invima_status_parser.dart';

class InvimaApiDataSource {
  InvimaApiDataSource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ));
  }

  late final Dio _dio;

  // URL completa para evitar ambigüedad con baseUrl
  static const _apiUrl      = 'https://www.datos.gov.co/resource/i7cb-raxc.json';
  static const _metadataUrl = 'https://www.datos.gov.co/api/views/i7cb-raxc.json';
  static const _limit       = 5;

  // La Ley 1712 de 2014 y la licencia CC BY-SA 4.0 de datos.gov.co exigen
  // mostrar la fuente y la fecha de corte de los datos abiertos que se
  // reutilizan. Este dataset se publica por lotes periódicos — no es un
  // espejo en vivo del sistema interno de INVIMA — así que esta fecha
  // puede tener semanas de rezago frente a cambios reales en el registro.
  // Se guarda en caché en memoria: no cambia seguido y no vale la pena
  // consultarla en cada pantalla de resultado.
  DateTime? _cachedLastUpdated;

  Future<DateTime?> getDatasetLastUpdated() async {
    if (_cachedLastUpdated != null) return _cachedLastUpdated;
    try {
      final response = await _dio.get(_metadataUrl);
      final data = response.data as Map<String, dynamic>;
      final epochSeconds = data['rowsUpdatedAt'] as int?;
      if (epochSeconds == null) return null;
      _cachedLastUpdated = DateTime.fromMillisecondsSinceEpoch(
        epochSeconds * 1000,
        isUtc: true,
      ).toLocal();
      return _cachedLastUpdated;
    } catch (e) {
      debugPrint('[INVIMA] Error obteniendo fecha de actualización del dataset: $e');
      return null;
    }
  }

  // Busca por registro sanitario (ej: "2008M-0007952" o "INVIMA 2008M-0007952").
  Future<MedicineModel?> findByRegistry(String registry) async {
    final clean       = registry.replaceAll(RegExp(r'^INVIMA\s*', caseSensitive: false), '').trim();
    final withoutDash = clean.replaceAll('-', '');

    // Intento 1: busca en el campo registrosanitario con guion
    var result = await _queryWhere(
      "upper(registrosanitario) like upper('%${InvimaStatusParser.escape(clean)}%')",
    );
    if (result != null) return result;

    // Intento 2: sin guion
    if (withoutDash != clean) {
      result = await _queryWhere(
        "upper(registrosanitario) like upper('%${InvimaStatusParser.escape(withoutDash)}%')",
      );
      if (result != null) return result;
    }

    // Sin fallback de texto libre aquí a propósito: un registro sanitario
    // es un identificador exacto, no una frase de búsqueda. Si no coincide
    // tal cual con el campo registrosanitario, el búsqueda de texto libre
    // de Socrata ($q) puede devolver OTRO medicamento cuyo nombre o
    // laboratorio comparte alguna palabra — lo que oculta justo el caso que
    // esta app existe para detectar: un código alterado/adulterado que no
    // corresponde a ningún registro real.
    return null;
  }

  // Busca por nombre del producto.
  Future<MedicineModel?> findByName(String name) async {
    // Intento 1: full-text (busca en todos los campos)
    final result = await _queryFullText(name);
    if (result != null) return result;

    // Intento 2: LIKE en campo producto
    return _queryWhere(
      "upper(producto) like upper('%${InvimaStatusParser.escape(name)}%')",
    );
  }

  // Búsqueda múltiple para historial/sugerencias.
  Future<List<MedicineModel>> search(String query) async {
    try {
      final response = await _dio.get(_apiUrl, queryParameters: {
        r'$q':     query,
        r'$limit': '$_limit',
      });
      final list = response.data as List<dynamic>;
      if (list.isNotEmpty) {
        return list
            .map((e) => _fromSocrata(e as Map<String, dynamic>))
            .whereType<MedicineModel>()
            .toList();
      }

      // Respaldo: LIKE en nombre
      final response2 = await _dio.get(_apiUrl, queryParameters: {
        r'$where': "upper(producto) like upper('%${InvimaStatusParser.escape(query)}%')",
        r'$limit': '$_limit',
      });
      final list2 = response2.data as List<dynamic>;
      return list2
          .map((e) => _fromSocrata(e as Map<String, dynamic>))
          .whereType<MedicineModel>()
          .toList();
    } catch (e) {
      debugPrint('[INVIMA] search error: $e');
      return [];
    }
  }

  // ── Helpers internos ─────────────────────────────────────────

  Future<MedicineModel?> _queryWhere(String where) async {
    try {
      debugPrint('[INVIMA] WHERE → $where');
      final response = await _dio.get(_apiUrl, queryParameters: {
        r'$where': where,
        r'$limit': '1',
      });
      final list = response.data as List<dynamic>;
      debugPrint('[INVIMA] WHERE result: ${list.length} items');
      if (list.isEmpty) return null;
      return _fromSocrata(list.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[INVIMA] WHERE error: $e');
      return null;
    }
  }

  Future<MedicineModel?> _queryFullText(String query) async {
    try {
      debugPrint('[INVIMA] \$q → $query');
      final response = await _dio.get(_apiUrl, queryParameters: {
        r'$q':     query,
        r'$limit': '1',
      });
      final list = response.data as List<dynamic>;
      debugPrint('[INVIMA] \$q result: ${list.length} items');
      if (list.isEmpty) return null;
      return _fromSocrata(list.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[INVIMA] \$q error: $e');
      return null;
    }
  }

  MedicineModel? _fromSocrata(Map<String, dynamic> json) {
    try {
      final rawStatus = (json['estadoregistro'] as String? ?? '').toLowerCase();
      // Concentración: combina cantidad + unidadmedida si están disponibles
      final cantidad  = json['cantidad']?.toString();
      final unidad    = json['unidadmedida'] as String?;
      final conc      = (cantidad != null && unidad != null)
          ? '$cantidad $unidad'
          : (json['concentracion'] as String?);

      return MedicineModel.fromJson({
        'id':            json['expediente'] ?? '',
        'nombre':        json['producto'] ?? 'Sin nombre',
        'registro':      json['registrosanitario'] ?? 'INVIMA ${json['expediente'] ?? ''}',
        'laboratorio':   json['nombrerol'] ?? json['titular'] ?? 'Desconocido',
        'titular':       json['titular'],
        'ingrediente':   json['principioactivo'],
        'concentracion': conc,
        'forma':         json['formafarmaceutica'],
        'estado':        InvimaStatusParser.normalizeStatus(rawStatus),
      });
    } catch (e) {
      debugPrint('[INVIMA] _fromSocrata error: $e');
      return null;
    }
  }
}
