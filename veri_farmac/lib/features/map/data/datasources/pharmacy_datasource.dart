// Consulta farmacias reales usando la API de OpenStreetMap (Overpass).
// Gratuita, sin API key. Datos reales actualizados por la comunidad OSM.

import 'package:dio/dio.dart';

class PharmacyDataSource {
  PharmacyDataSource(this._dio);
  final Dio _dio;

  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Radio de búsqueda en metros alrededor de la ubicación
  static const _radiusMeters = 3000;

  // Coordenadas del centro de Pasto como respaldo si no hay GPS
  static const _pastoLat = 1.2136;
  static const _pastoLng = -77.2811;

  Future<List<Map<String, dynamic>>> findNearby({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude  ?? _pastoLat;
    final lng = longitude ?? _pastoLng;

    // Query Overpass QL: busca nodos y áreas con amenity=pharmacy en el radio
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"](around:$_radiusMeters,$lat,$lng);
  way["amenity"="pharmacy"](around:$_radiusMeters,$lat,$lng);
);
out center;
''';

    final response = await _dio.post(
      _overpassUrl,
      data: query,
      options: Options(
        contentType: 'text/plain',
        responseType: ResponseType.json,
      ),
    );

    final elements = response.data['elements'] as List<dynamic>? ?? [];

    return elements
        .map((e) => _parseElement(e as Map<String, dynamic>))
        .where((p) => p != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? _parseElement(Map<String, dynamic> element) {
    // Los nodos tienen lat/lon directos; las vías tienen un centro calculado
    final lat = (element['lat'] as num?)?.toDouble()
        ?? (element['center']?['lat'] as num?)?.toDouble();
    final lng = (element['lon'] as num?)?.toDouble()
        ?? (element['center']?['lon'] as num?)?.toDouble();

    if (lat == null || lng == null) return null;

    final tags = element['tags'] as Map<String, dynamic>? ?? {};

    final name    = tags['name'] as String?
        ?? tags['brand'] as String?
        ?? 'Farmacia';
    final address = _buildAddress(tags);

    return {
      'name':      name,
      'address':   address,
      'latitude':  lat,
      'longitude': lng,
      'phone':     tags['phone'] as String?,
      'opening':   tags['opening_hours'] as String?,
    };
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[
      if (tags['addr:street'] != null) tags['addr:street'] as String,
      if (tags['addr:housenumber'] != null) tags['addr:housenumber'] as String,
    ];
    return parts.isNotEmpty ? parts.join(' # ') : 'Pasto, Nariño';
  }
}
