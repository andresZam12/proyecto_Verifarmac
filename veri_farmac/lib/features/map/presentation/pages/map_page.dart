import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controladorMapa;
  final _farmacias = [
    {'nombre': 'Farmacia Cruz Verde', 'direccion': 'Cra 15 #93-75',       'latitud': 4.676, 'longitud': -74.048},
    {'nombre': 'Droguería La Rebaja', 'direccion': 'Cll 100 #15-10',      'latitud': 4.678, 'longitud': -74.050},
    {'nombre': 'Farmatodo',           'direccion': 'Av El Dorado #68C-61', 'latitud': 4.674, 'longitud': -74.052},
  ];

  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(mapProvider.notifier).obtenerUbicacion()); }

  @override
  void dispose() { _controladorMapa?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Farmacias cercanas')),
      body: Builder(builder: (context) {
        if (state.cargando)   return const AppLoading(mensaje: 'Obteniendo ubicación...');
        if (state.sinPermiso) return Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.location_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Se necesita acceso a tu ubicación', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(mapProvider.notifier).obtenerUbicacion(),
              child: const Text('Permitir ubicación'),
            ),
          ]),
        ));
        if (state.error != null) return Center(child: Text(state.error!));
        final pos = state.posicion!;
        return GoogleMap(
          onMapCreated:            (c) => _controladorMapa = c,
          initialCameraPosition:   CameraPosition(target: LatLng(pos.latitud, pos.longitud), zoom: 15),
          myLocationEnabled:       true,
          myLocationButtonEnabled: true,
          markers: PharmacyMarker.crear(
            farmacias:   _farmacias,
            alPresionar: (n) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n))),
          ),
        );
      }),
    );
  }
}
