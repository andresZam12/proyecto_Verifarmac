import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class MapState {
  const MapState({this.posicion, this.cargando = false, this.sinPermiso = false, this.error});
  final PosicionGeo? posicion;
  final bool         cargando;
  final bool         sinPermiso;
  final String?      error;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation) : super(const MapState());
  final GetLocationUseCase _getLocation;

  Future<void> obtenerUbicacion() async {
    state = const MapState(cargando: true);
    try {
      final posicion = await _getLocation();
      state = posicion == null ? const MapState(sinPermiso: true) : MapState(posicion: posicion);
    } catch (_) {
      state = const MapState(error: 'Error al obtener ubicación');
    }
  }
}

final _datasourceProvider = Provider((_) => LocationDataSource());
final _repositoryProvider = Provider((ref) => LocationRepositoryImpl(ref.read(_datasourceProvider)));
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(GetLocationUseCase(ref.read(_repositoryProvider))));
