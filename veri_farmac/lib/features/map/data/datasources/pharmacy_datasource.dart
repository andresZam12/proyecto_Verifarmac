import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PharmacyDataSource {
  PharmacyDataSource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'User-Agent': 'VeriFarmac/1.0 (verifarmac@example.com)'},
    ));
  }

  late final Dio _dio;

  static const _pastoLat = 1.2136;
  static const _pastoLng = -77.2811;
  // ~8 km en grados
  static const _delta = 0.08;

  Future<List<Map<String, dynamic>>> findNearby({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude  ?? _pastoLat;
    final lng = longitude ?? _pastoLng;

    // Bounding box: west, north, east, south
    final viewbox = '${lng - _delta},${lat + _delta},${lng + _delta},${lat - _delta}';

    // Intenta primero con amenity=pharmacy, luego con búsqueda de texto
    var results = await _searchNominatim({'amenity': 'pharmacy'}, viewbox);
    if (results.isEmpty) {
      results = await _searchNominatim({'q': 'farmacia drogueria'}, viewbox);
    }

    debugPrint('[Pharmacy] ${results.length} resultados para ($lat, $lng)');
    return results;
  }

  Future<List<Map<String, dynamic>>> _searchNominatim(
    Map<String, String> extra,
    String viewbox,
  ) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format':       'json',
          'limit':        '30',
          'bounded':      '1',
          'viewbox':      viewbox,
          'countrycodes': 'co',
          'addressdetails': '0',
          ...extra,
        },
      );

      final list = response.data as List<dynamic>;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        // Toma el nombre corto antes de la primera coma del display_name
        final display = m['display_name'] as String? ?? 'Farmacia';
        final name    = (m['name'] as String?)?.isNotEmpty == true
            ? m['name'] as String
            : display.split(',').first.trim();
        return {
          'name':      name,
          'address':   display,
          'latitude':  double.parse(m['lat'] as String),
          'longitude': double.parse(m['lon'] as String),
        };
      }).toList();
    } catch (e) {
      debugPrint('[Pharmacy] Nominatim error: $e');
      return [];
    }
  }
}
