import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_provider.dart';

const _kBlue  = Color(0xFF00478D);
const _kWhite = Colors.white;

class HospitalMarker {
  static List<Marker> create({
    required List<HospitalData> hospitals,
    required void Function(HospitalData) onPress,
  }) {
    return hospitals.map((h) => _buildMarker(h, onPress)).toList();
  }

  static Marker _buildMarker(
      HospitalData h, void Function(HospitalData) onPress) {
    return Marker(
      point:  LatLng(h.lat, h.lng),
      width:  72,
      height: 80,
      child: GestureDetector(
        onTap: () => onPress(h),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin circular grande
            Container(
              width:  56,
              height: 56,
              decoration: BoxDecoration(
                color: _kBlue,
                shape: BoxShape.circle,
                border: Border.all(color: _kWhite, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _kBlue.withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: _kWhite,
                size: 28,
              ),
            ),
            // Punta del pin
            CustomPaint(
              size: const Size(14, 10),
              painter: _PinTailPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kBlue
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
