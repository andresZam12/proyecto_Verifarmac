// Implementación del repositorio de ubicación.

import '../../domain/usecases/get_location_usecase.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements ILocationRepository {
  const LocationRepositoryImpl(this._datasource);
  final LocationDataSource _datasource;

  @override
  Future<GeoPosition?> getPosition() async {
    try {
      return await _datasource.getPosition();
    } catch (e) {
      return null; // si falla, retorna null en vez de lanzar excepción
    }
  }

  @override
  Future<bool> requestPermission() {
    return _datasource.requestPermission();
  }
}
