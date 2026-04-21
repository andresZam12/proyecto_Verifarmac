import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PharmacyMarker {
  static List<Marker> create({
    required List<Map<String, dynamic>> pharmacies,
    required Function(String name) onPress,
  }) {
    return pharmacies.map((p) {
      final name = p['name'] as String? ?? 'Farmacia';
      return Marker(
        point: LatLng(p['latitude'] as double, p['longitude'] as double),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => onPress(name),
          child: const Icon(
            Icons.local_pharmacy_rounded,
            color: Colors.blue,
            size: 32,
          ),
        ),
      );
    }).toList();
  }

  static Marker userLocation(double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}
