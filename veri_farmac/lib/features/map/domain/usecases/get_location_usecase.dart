// Caso de uso: obtener ubicación actual.
// TODO: llamar a ILocationRepository.getCurrentPosition()

// Caso de uso: obtener la ubicación actual del dispositivo.
class GetLocationUseCase {
  const GetLocationUseCase(this._repo);
  final ILocationRepository _repo;

  Future<PosicionGeo?> call() => _repo.obtenerPosicion();
}

// Entidad simple de posición geográfica
class PosicionGeo {
  const PosicionGeo({required this.latitud, required this.longitud});
  final double latitud;
  final double longitud;
}

// Contrato del repositorio de ubicación
abstract class ILocationRepository {
  Future<PosicionGeo?> obtenerPosicion();
  Future<bool> solicitarPermiso();
}