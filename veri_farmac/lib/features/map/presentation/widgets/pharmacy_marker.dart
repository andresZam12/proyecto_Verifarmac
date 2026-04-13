import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyMarker {
  static Set<Marker> create({
    required List<Map<String, dynamic>> pharmacies,
    required Function(String name) onPress,
  }) {
    return pharmacies.asMap().entries.map((entry) {
      final p = entry.value;
      return Marker(
        markerId:   MarkerId('pharmacy_${entry.key}'),
        position:   LatLng(p['latitude'] as double, p['longitude'] as double),
        infoWindow: InfoWindow(
          title:   p['name'] as String,
          snippet: p['address'] as String? ?? '',
        ),
        icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () => onPress(p['name'] as String),
      );
    }).toSet();
  }
}
