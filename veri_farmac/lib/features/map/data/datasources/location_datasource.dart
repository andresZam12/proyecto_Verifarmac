import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_location_usecase.dart';

class LocationDataSource {
  Future<PosicionGeo?> obtenerPosicion() async {
    final tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;
    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return PosicionGeo(latitud: p.latitude, longitud: p.longitude);
  }

  Future<bool> solicitarPermiso() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }
}
