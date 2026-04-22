import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/datasources/pharmacy_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class MapState {
  const MapState({
    this.position,
    this.pharmacies       = const [],
    this.isLoading        = false,
    this.permissionDenied = false,
  });
  final GeoPosition?               position;
  final List<Map<String, dynamic>> pharmacies;
  final bool                       isLoading;
  final bool                       permissionDenied;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation, this._pharmacy) : super(const MapState());

  final GetLocationUseCase _getLocation;
  final PharmacyDataSource _pharmacy;

  Future<void> load() async {
    state = const MapState(isLoading: true);

    GeoPosition? position;
    try {
      position = await _getLocation();
    } catch (_) {}

    final pharmacies = await _pharmacy.findNearby(
      latitude:  position?.latitude,
      longitude: position?.longitude,
    );

    state = MapState(
      position:         position,
      pharmacies:       pharmacies,
      permissionDenied: position == null,
    );
  }
}

final _locationDatasourceProvider = Provider((_) => LocationDataSource());
final _locationRepositoryProvider = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_locationDatasourceProvider)),
);
final _pharmacyProvider = Provider((_) => PharmacyDataSource());

final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(
    GetLocationUseCase(ref.read(_locationRepositoryProvider)),
    ref.read(_pharmacyProvider),
  ),
);
