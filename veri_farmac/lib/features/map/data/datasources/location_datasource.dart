import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_location_usecase.dart';

class LocationDataSource {
  Future<GeoPosition?> getPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return GeoPosition(latitude: p.latitude, longitude: p.longitude);
  }

  Future<bool> requestPermission() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }
}
