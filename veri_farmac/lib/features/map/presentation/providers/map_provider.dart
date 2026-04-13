import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/datasources/pharmacy_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';
import '../../../../../core/constants/app_strings.dart';

class MapState {
  const MapState({
    this.position,
    this.pharmacies        = const [],
    this.isLoading         = false,
    this.permissionDenied  = false,
    this.error,
  });
  final GeoPosition?              position;
  final List<Map<String, dynamic>> pharmacies;
  final bool                      isLoading;
  final bool                      permissionDenied;
  final String?                   error;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation, this._pharmacyDataSource)
      : super(const MapState());

  final GetLocationUseCase  _getLocation;
  final PharmacyDataSource  _pharmacyDataSource;

  Future<void> fetchLocation() async {
    state = const MapState(isLoading: true);
    try {
      final position = await _getLocation();

      if (position == null) {
        // Sin permiso — igual carga farmacias en Pasto como fallback
        final pharmacies = await _pharmacyDataSource.findNearby();
        state = MapState(permissionDenied: true, pharmacies: pharmacies);
        return;
      }

      // Carga farmacias reales cerca de la ubicación del usuario
      final pharmacies = await _pharmacyDataSource.findNearby(
        latitude:  position.latitude,
        longitude: position.longitude,
      );

      state = MapState(position: position, pharmacies: pharmacies);
    } catch (_) {
      state = const MapState(error: AppStrings.errorGetLocation);
    }
  }
}

final _locationDatasourceProvider  = Provider((_) => LocationDataSource());
final _locationRepositoryProvider  = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_locationDatasourceProvider)),
);
final _pharmacyDatasourceProvider  = Provider((_) => PharmacyDataSource(Dio()));

final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(
    GetLocationUseCase(ref.read(_locationRepositoryProvider)),
    ref.read(_pharmacyDatasourceProvider),
  ),
);
