import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';
import '../../../../../core/constants/app_strings.dart';

class MapState {
  const MapState({
    this.position,
    this.isLoading       = false,
    this.permissionDenied = false,
    this.error,
  });
  final GeoPosition? position;
  final bool         isLoading;
  final bool         permissionDenied;
  final String?      error;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation) : super(const MapState());
  final GetLocationUseCase _getLocation;

  Future<void> fetchLocation() async {
    state = const MapState(isLoading: true);
    try {
      final position = await _getLocation();
      state = position == null
          ? const MapState(permissionDenied: true)
          : MapState(position: position);
    } catch (_) {
      state = const MapState(error: AppStrings.errorGetLocation);
    }
  }
}

final _datasourceProvider = Provider((_) => LocationDataSource());
final _repositoryProvider = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_datasourceProvider)),
);
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(GetLocationUseCase(ref.read(_repositoryProvider))),
);
