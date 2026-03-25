import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyMarker {
  static Set<Marker> crear({
    required List<Map<String, dynamic>> farmacias,
    required Function(String nombre) alPresionar,
  }) {
    return farmacias.asMap().entries.map((entry) {
      final f = entry.value;
      return Marker(
        markerId:   MarkerId('farmacia_${entry.key}'),
        position:   LatLng(f['latitud'] as double, f['longitud'] as double),
        infoWindow: InfoWindow(title: f['nombre'] as String, snippet: f['direccion'] as String? ?? ''),
        icon:       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap:      () => alPresionar(f['nombre'] as String),
      );
    }).toSet();
  }
}
