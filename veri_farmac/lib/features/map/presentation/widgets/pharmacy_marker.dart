// Marcador personalizado para farmacias en el mapa.
// TODO: implementar con BitmapDescriptor

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Crea un marcador personalizado para mostrar una farmacia en el mapa.
class PharmacyMarker {

  // Retorna un Set de marcadores para mostrar en el mapa
  static Set<Marker> crear({
    required List<Map<String, dynamic>> farmacias,
    required Function(String nombre) alPresionar,
  }) {
    return farmacias.asMap().entries.map((entry) {
      final farmacia = entry.value;
      return Marker(
        markerId: MarkerId('farmacia_${entry.key}'),
        position: LatLng(
          farmacia['latitud'] as double,
          farmacia['longitud'] as double,
        ),
        infoWindow: InfoWindow(
          title: farmacia['nombre'] as String,
          snippet: farmacia['direccion'] as String? ?? '',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue, // azul para diferenciar de marcadores normales
        ),
        onTap: () => alPresionar(farmacia['nombre'] as String),
      );
    }).toSet();
  }
}