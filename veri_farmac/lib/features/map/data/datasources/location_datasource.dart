// Datasource de ubicación con geolocator.
// TODO: implementar getCurrentPosition y requestPermission

import 'package:geolocator/geolocator.dart';

import '../../../map/domain/usecases/get_location_usecase.dart';

// Obtiene la ubicación real del dispositivo usando geolocator.
class LocationDataSource {

  // Solicita permiso y retorna la posición actual
  Future<PosicionGeo?> obtenerPosicion() async {
    final tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;

    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return PosicionGeo(
      latitud: posicion.latitude,
      longitud: posicion.longitude,
    );
  }

  // Verifica y solicita permiso de ubicación
  Future<bool> solicitarPermiso() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    return permiso == LocationPermission.always ||
        permiso == LocationPermission.whileInUse;
  }
}