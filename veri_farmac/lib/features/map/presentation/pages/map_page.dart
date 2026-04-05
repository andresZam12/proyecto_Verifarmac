import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;

  // Farmacias de ejemplo — en producción vendrían de una API real
  final _pharmacies = [
    {'name': 'Farmacia Cruz Verde', 'address': 'Cra 15 #93-75',       'latitude': 4.676, 'longitude': -74.048},
    {'name': 'Droguería La Rebaja', 'address': 'Cll 100 #15-10',      'latitude': 4.678, 'longitude': -74.050},
    {'name': 'Farmatodo',           'address': 'Av El Dorado #68C-61', 'latitude': 4.674, 'longitude': -74.052},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapProvider.notifier).fetchLocation());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final l10n  = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nearbyPharmacies)),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return AppLoading(message: l10n.gettingLocation);
        }
        if (state.permissionDenied) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_off_rounded, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.locationPermissionNeeded, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(mapProvider.notifier).fetchLocation(),
                  child: Text(l10n.allowLocation),
                ),
              ]),
            ),
          );
        }
        if (state.error != null) {
          return Center(child: Text(state.error!));
        }
        final pos = state.position!;
        return GoogleMap(
          onMapCreated:            (c) => _mapController = c,
          initialCameraPosition:   CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 15,
          ),
          myLocationEnabled:       true,
          myLocationButtonEnabled: true,
          markers: PharmacyMarker.create(
            pharmacies: _pharmacies,
            onPress: (name) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(name))),
          ),
        );
      }),
    );
  }
}
