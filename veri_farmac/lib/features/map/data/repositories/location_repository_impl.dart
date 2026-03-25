// Implementación del repositorio de ubicación.
// TODO: conectar geolocator con dominio, manejar permisos

import '../../domain/usecases/get_location_usecase.dart';
import '../datasources/location_datasource.dart';

// Implementa ILocationRepository usando geolocator.
class LocationRepositoryImpl implements ILocationRepository {
  const LocationRepositoryImpl(this._datasource);
  final LocationDataSource _datasource;

  @override
  Future<PosicionGeo?> obtenerPosicion() async {
    try {
      return await _datasource.obtenerPosicion();
    } catch (e) {
      return null; // si falla, retorna null en vez de lanzar excepción
    }
  }

  @override
  Future<bool> solicitarPermiso() {
    return _datasource.solicitarPermiso();
  }
}