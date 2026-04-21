import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/datasources/pharmacy_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class MapState {
  const MapState({
    this.position,
    this.pharmacies        = const [],
    this.isLoading         = false,
    this.permissionDenied  = false,
    this.pharmacyError,
    this.error,
  });
  final GeoPosition?               position;
  final List<Map<String, dynamic>> pharmacies;
  final bool                       isLoading;
  final bool                       permissionDenied;
  final String?                    pharmacyError; // error solo al cargar farmacias
  final String?                    error;         // error crítico (ubicación)
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation, this._pharmacyDataSource)
      : super(const MapState());

  final GetLocationUseCase  _getLocation;
  final PharmacyDataSource  _pharmacyDataSource;

  Future<void> fetchLocation() async {
    state = const MapState(isLoading: true);

    // Paso 1: obtener ubicación (devuelve null si no hay permiso)
    GeoPosition? position;
    try {
      position = await _getLocation();
    } catch (e) {
      debugPrint('[Map] Error GPS: $e');
    }

    // Paso 2: cargar farmacias (usa Pasto como fallback si no hay GPS)
    List<Map<String, dynamic>> pharmacies = [];
    String? pharmacyError;
    try {
      pharmacies = await _pharmacyDataSource.findNearby(
        latitude:  position?.latitude,
        longitude: position?.longitude,
      );
    } catch (e) {
      debugPrint('[Map] Error Overpass API: $e');
      pharmacyError = 'No se pudieron cargar las farmacias. Intenta de nuevo.';
    }

    state = MapState(
      position:       position,
      pharmacies:     pharmacies,
      permissionDenied: position == null,
      pharmacyError:  pharmacyError,
    );
  }
}

final _locationDatasourceProvider = Provider((_) => LocationDataSource());
final _locationRepositoryProvider = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_locationDatasourceProvider)),
);
final _pharmacyDatasourceProvider = Provider((_) => PharmacyDataSource(null));

final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(
    GetLocationUseCase(ref.read(_locationRepositoryProvider)),
    ref.read(_pharmacyDatasourceProvider),
  ),
);
