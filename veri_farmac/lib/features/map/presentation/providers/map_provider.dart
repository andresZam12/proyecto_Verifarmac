import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class HospitalData {
  const HospitalData({
    required this.name,
    required this.address,
    required this.description,
    required this.lat,
    required this.lng,
  });
  final String name;
  final String address;
  final String description;
  final double lat;
  final double lng;
}

class MapState {
  const MapState({
    this.position,
    this.hospitals = const [],
    this.selectedHospital,
    this.isLoading = false,
  });
  final GeoPosition?       position;
  final List<HospitalData> hospitals;
  final HospitalData?      selectedHospital;
  final bool               isLoading;

  MapState copyWith({
    GeoPosition?        position,
    List<HospitalData>? hospitals,
    HospitalData?       selectedHospital,
    bool?               isLoading,
    bool                clearSelected = false,
  }) =>
      MapState(
        position:         position         ?? this.position,
        hospitals:        hospitals        ?? this.hospitals,
        selectedHospital: clearSelected
            ? null
            : (selectedHospital ?? this.selectedHospital),
        isLoading: isLoading ?? this.isLoading,
      );
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation) : super(const MapState());
  final GetLocationUseCase _getLocation;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent': 'VeriFarmac/1.0 (Flutter; Android)',
      'Accept': 'application/json',
    },
  ));

  Future<void> load() async {
    state = const MapState(isLoading: true);

    GeoPosition? position;
    try {
      position = await _getLocation();
    } catch (_) {}

    state = MapState(position: position, isLoading: true);

    final cLat = position?.latitude  ?? 1.2136;
    final cLng = position?.longitude ?? -77.2811;

    final hospitals = await _fetchNearbyHospitals(cLat, cLng);
    state = MapState(position: position, hospitals: hospitals);
  }

  Future<List<HospitalData>> _fetchNearbyHospitals(
      double lat, double lng) async {
    // Intenta Nominatim primero (GET simple, muy confiable)
    final nominatim = await _fetchFromNominatim(lat, lng);
    if (nominatim.isNotEmpty) return nominatim;

    // Fallback: Overpass API (POST)
    final overpass = await _fetchFromOverpass(lat, lng);
    if (overpass.isNotEmpty) return overpass;

    return const [];
  }

  // ── Nominatim ────────────────────────────────────────────────────────────────

  Future<List<HospitalData>> _fetchFromNominatim(
      double lat, double lng) async {
    const delta = 0.05; // ~5.5 km
    // viewbox = oeste,norte,este,sur
    final viewbox =
        '${lng - delta},${lat + delta},${lng + delta},${lat - delta}';

    final result = <HospitalData>[];

    for (final amenity in ['hospital', 'clinic']) {
      try {
        final response = await _dio.get<String>(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'amenity':      amenity,
            'format':       'json',
            'limit':        '50',
            'viewbox':      viewbox,
            'bounded':      '1',
            'addressdetails': '1',
            'namedetails':  '1',
          },
          options: Options(responseType: ResponseType.plain),
        );

        final raw = response.data ?? '';
        if (raw.isEmpty) continue;

        final list = jsonDecode(raw);
        if (list is! List) continue;

        for (final item in list) {
          final nameDetails = item['namedetails'] as Map?;
          final address     = item['address']     as Map?;

          final name =
              (nameDetails?['name']         as String?) ??
              (nameDetails?['name:es']      as String?) ??
              (address?['amenity']          as String?) ??
              (item['display_name'] as String?)?.split(',').first.trim();

          if (name == null || name.trim().isEmpty) continue;

          final eLat = double.tryParse(item['lat'] as String? ?? '');
          final eLng = double.tryParse(item['lon'] as String? ?? '');
          if (eLat == null || eLng == null) continue;

          final road   = address?['road']         as String?;
          final city   = address?['city']         as String?
              ?? address?['town']     as String?
              ?? address?['village']  as String?
              ?? 'Pasto';
          final addrStr = road != null ? '$road, $city' : city;

          result.add(HospitalData(
            name:        name.trim(),
            address:     addrStr,
            description: amenity == 'hospital'
                ? 'Hospital con atención de urgencias, consulta externa y hospitalización.'
                : 'Clínica con atención médica general y especializada.',
            lat: eLat,
            lng: eLng,
          ));
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  // ── Overpass API ─────────────────────────────────────────────────────────────

  Future<List<HospitalData>> _fetchFromOverpass(
      double lat, double lng) async {
    final query = '[out:json][timeout:25];'
        '('
        'node["amenity"="hospital"]["name"](around:5000,$lat,$lng);'
        'node["amenity"="clinic"]["name"](around:5000,$lat,$lng);'
        'way["amenity"="hospital"]["name"](around:5000,$lat,$lng);'
        'way["amenity"="clinic"]["name"](around:5000,$lat,$lng);'
        'relation["amenity"="hospital"]["name"](around:5000,$lat,$lng);'
        'relation["amenity"="clinic"]["name"](around:5000,$lat,$lng);'
        ');'
        'out center;';

    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final url in endpoints) {
      try {
        final response = await _dio.post<String>(
          url,
          data: 'data=${Uri.encodeComponent(query)}',
          options: Options(
            contentType: 'application/x-www-form-urlencoded',
            responseType: ResponseType.plain,
          ),
        );

        final raw = response.data ?? '';
        if (raw.isEmpty) continue;

        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final elements = (decoded['elements'] as List?) ?? [];
        final result   = _parseOverpassElements(elements);
        if (result.isNotEmpty) return result;
      } catch (_) {
        continue;
      }
    }

    return const [];
  }

  List<HospitalData> _parseOverpassElements(List<dynamic> elements) {
    final result = <HospitalData>[];
    for (final el in elements) {
      final tags = ((el['tags'] as Map?) ?? {}).cast<String, dynamic>();
      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      double? eLat, eLng;
      if (el['type'] == 'node') {
        eLat = (el['lat'] as num?)?.toDouble();
        eLng = (el['lon'] as num?)?.toDouble();
      } else {
        eLat = (el['center']?['lat'] as num?)?.toDouble();
        eLng = (el['center']?['lon'] as num?)?.toDouble();
      }
      if (eLat == null || eLng == null || eLat.isNaN || eLng.isNaN) continue;

      final street  = tags['addr:street']      as String?;
      final number  = tags['addr:housenumber'] as String?;
      final city    = tags['addr:city']        as String? ?? 'Pasto';
      final address = street != null
          ? '$street${number != null ? " #$number" : ""}, $city'
          : city;

      result.add(HospitalData(
        name:        name,
        address:     address,
        description: _buildDescription(tags),
        lat:         eLat,
        lng:         eLng,
      ));
    }
    return result;
  }

  String _buildDescription(Map<String, dynamic> tags) {
    final amenity  = tags['amenity']  as String? ?? '';
    final operator = tags['operator'] as String?;
    if (amenity == 'hospital') {
      return operator != null
          ? 'Hospital operado por $operator. Urgencias, UCI y especialidades médicas.'
          : 'Hospital con atención de urgencias, consulta externa y hospitalización.';
    }
    return 'Clínica con atención médica general y especializada.';
  }

  void selectHospital(HospitalData? hospital) {
    state = state.copyWith(
      clearSelected:    hospital == null,
      selectedHospital: hospital,
    );
  }
}

final _locationDatasourceProvider = Provider((_) => LocationDataSource());
final _locationRepositoryProvider = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_locationDatasourceProvider)),
);

final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(
    GetLocationUseCase(ref.read(_locationRepositoryProvider)),
  ),
);
