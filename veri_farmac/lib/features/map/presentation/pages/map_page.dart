import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

// Coordenadas del centro de Pasto como vista inicial mientras carga el GPS
const _pastoCenterLat = 1.2136;
const _pastoCenterLng = -77.2811;

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;

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
      appBar: AppBar(
        title: Text(l10n.nearbyPharmacies),
        actions: [
          // Contador de farmacias encontradas
          if (state.pharmacies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${state.pharmacies.length} encontradas',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return AppLoading(message: l10n.gettingLocation);
        }

        if (state.permissionDenied) {
          return Column(children: [
            // Aun sin permiso mostramos las farmacias en Pasto
            Expanded(child: _buildMap(state, centerOnPasto: true)),
            _PermissionBanner(
              message: l10n.locationPermissionNeeded,
              onRetry: () => ref.read(mapProvider.notifier).fetchLocation(),
              label: l10n.allowLocation,
            ),
          ]);
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return _buildMap(state, centerOnPasto: false);
      }),
    );
  }

  Widget _buildMap(MapState state, {required bool centerOnPasto}) {
    final lat = centerOnPasto
        ? _pastoCenterLat
        : state.position!.latitude;
    final lng = centerOnPasto
        ? _pastoCenterLng
        : state.position!.longitude;

    return Stack(children: [
      GoogleMap(
        onMapCreated:            (c) => _mapController = c,
        initialCameraPosition:   CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ),
        myLocationEnabled:       !centerOnPasto,
        myLocationButtonEnabled: !centerOnPasto,
        markers: PharmacyMarker.create(
          pharmacies: state.pharmacies,
          onPress: (name) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(name))),
        ),
      ),
      // Banner de carga de farmacias mientras el mapa ya se ve
      if (state.isLoading)
        const Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Buscando farmacias...'),
              ]),
            ),
          ),
        ),
    ]);
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.message,
    required this.onRetry,
    required this.label,
  });
  final String   message;
  final VoidCallback onRetry;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(children: [
        const Icon(Icons.location_off_rounded, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: const TextStyle(fontSize: 13)),
        ),
        TextButton(onPressed: onRetry, child: Text(label)),
      ]),
    );
  }
}
