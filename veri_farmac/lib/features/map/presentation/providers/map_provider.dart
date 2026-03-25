// Estado del mapa con Riverpod.
// TODO: implementar MapNotifier con GetLocationUseCase

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class MapState {
  const MapState({
    this.posicion,
    this.cargando = false,
    this.sinPermiso = false,
    this.error,
  });

  final PosicionGeo? posicion;
  final bool         cargando;
  final bool         sinPermiso;  // true si el usuario negó el permiso
  final String?      error;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation) : super(const MapState());

  final GetLocationUseCase _getLocation;

  // Obtiene la ubicación actual
  Future<void> obtenerUbicacion() async {
    state = const MapState(cargando: true);
    try {
      final posicion = await _getLocation();
      if (posicion == null) {
        state = const MapState(sinPermiso: true);
      } else {
        state = MapState(posicion: posicion);
      }
    } catch (e) {
      state = MapState(error: 'Error al obtener ubicación');
    }
  }
}

// Providers
final _datasourceProvider  = Provider((_) => LocationDataSource());
final _repositoryProvider  = Provider(
  (ref) => LocationRepositoryImpl(ref.read(_datasourceProvider)),
);

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(GetLocationUseCase(ref.read(_repositoryProvider)));
});
