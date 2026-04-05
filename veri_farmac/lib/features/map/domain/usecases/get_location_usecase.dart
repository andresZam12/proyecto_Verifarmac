// Caso de uso: obtener la ubicación actual del dispositivo.

// Entidad simple de posición geográfica
class GeoPosition {
  const GeoPosition({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

// Contrato del repositorio de ubicación
abstract class ILocationRepository {
  Future<GeoPosition?> getPosition();
  Future<bool> requestPermission();
}

// Caso de uso
class GetLocationUseCase {
  const GetLocationUseCase(this._repo);
  final ILocationRepository _repo;

  Future<GeoPosition?> call() => _repo.getPosition();
}
