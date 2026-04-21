import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PharmacyDataSource {
  PharmacyDataSource(Dio? dio) {
    _dio = dio ??
        Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ));
  }

  late final Dio _dio;

  // Servidores públicos de Overpass en orden de prioridad
  static const _servers = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static const _radiusMeters = 3000;
  static const _pastoLat = 1.2136;
  static const _pastoLng = -77.2811;

  Future<List<Map<String, dynamic>>> findNearby({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude  ?? _pastoLat;
    final lng = longitude ?? _pastoLng;

    final query = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"](around:$_radiusMeters,$lat,$lng);
  way["amenity"="pharmacy"](around:$_radiusMeters,$lat,$lng);
);
out center;
''';

    // Intenta cada servidor hasta que uno responda
    Object? lastError;
    for (final url in _servers) {
      try {
        debugPrint('[Pharmacy] Consultando $url');
        final response = await _dio.post(
          url,
          // Form-encoded: Overpass espera el parámetro "data"
          data: {'data': query},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.json,
          ),
        );

        final elements = response.data['elements'] as List<dynamic>? ?? [];
        final result = elements
            .map((e) => _parseElement(e as Map<String, dynamic>))
            .whereType<Map<String, dynamic>>()
            .toList();

        debugPrint('[Pharmacy] ${result.length} farmacias encontradas');
        return result;
      } catch (e) {
        debugPrint('[Pharmacy] Error en $url: $e');
        lastError = e;
      }
    }

    throw lastError ?? Exception('No se pudo contactar ningún servidor de farmacias');
  }

  Map<String, dynamic>? _parseElement(Map<String, dynamic> element) {
    final lat = (element['lat'] as num?)?.toDouble()
        ?? (element['center']?['lat'] as num?)?.toDouble();
    final lng = (element['lon'] as num?)?.toDouble()
        ?? (element['center']?['lon'] as num?)?.toDouble();

    if (lat == null || lng == null) return null;

    final tags    = element['tags'] as Map<String, dynamic>? ?? {};
    final name    = tags['name'] as String?
        ?? tags['brand'] as String?
        ?? 'Farmacia';

    return {
      'name':      name,
      'address':   _buildAddress(tags),
      'latitude':  lat,
      'longitude': lng,
      'phone':     tags['phone'] as String?,
      'opening':   tags['opening_hours'] as String?,
    };
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[
      if (tags['addr:street']      != null) tags['addr:street']      as String,
      if (tags['addr:housenumber'] != null) tags['addr:housenumber'] as String,
    ];
    return parts.isNotEmpty ? parts.join(' # ') : 'Pasto, Nariño';
  }
}
