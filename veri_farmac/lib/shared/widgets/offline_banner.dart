// Banner que aparece cuando no hay conexión.

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider que escucha cambios de conectividad en tiempo real
final conexionProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (resultado) => resultado != ConnectivityResult.none,
      );
});

// Banner que aparece automáticamente cuando no hay internet.
// Se coloca en la parte superior de las pantallas principales.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexion = ref.watch(conexionProvider);

    // Solo muestra el banner cuando definitivamente no hay conexión
    final sinConexion = conexion.whenOrNull(data: (conectado) => !conectado);

    if (sinConexion != true) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Sin conexión — mostrando datos locales',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}