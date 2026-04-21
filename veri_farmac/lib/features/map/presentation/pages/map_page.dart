import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

const _pastoCenterLat = 1.2136;
const _pastoCenterLng = -77.2811;

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapProvider.notifier).fetchLocation());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final l10n  = context.l10n;

    // Cuando llega la posición real, centrar el mapa
    ref.listen(mapProvider, (prev, next) {
      if (next.position != null && prev?.position == null) {
        _mapController.move(
          LatLng(next.position!.latitude, next.position!.longitude),
          14,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyPharmacies),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                state.pharmacies.isEmpty
                    ? 'Sin resultados OSM'
                    : '${state.pharmacies.length} encontradas',
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

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return Column(children: [
          Expanded(child: _buildMap(state)),
          if (state.pharmacyError != null)
            _InfoBanner(
              message: state.pharmacyError!,
              icon: Icons.warning_amber_rounded,
              onRetry: () => ref.read(mapProvider.notifier).fetchLocation(),
              label: 'Reintentar',
            ),
          if (state.permissionDenied)
            _PermissionBanner(
              message: l10n.locationPermissionNeeded,
              onRetry: () => ref.read(mapProvider.notifier).fetchLocation(),
              label: l10n.allowLocation,
            ),
        ]);
      }),
    );
  }

  Widget _buildMap(MapState state) {
    final lat = state.position?.latitude  ?? _pastoCenterLat;
    final lng = state.position?.longitude ?? _pastoCenterLng;

    final pharmacyMarkers = PharmacyMarker.create(
      pharmacies: state.pharmacies,
      onPress: (name) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(name))),
    );

    if (state.position != null) {
      pharmacyMarkers.add(
        PharmacyMarker.userLocation(lat, lng),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(lat, lng),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.verifarmac.app',
        ),
        MarkerLayer(markers: pharmacyMarkers),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
    required this.icon,
    required this.onRetry,
    required this.label,
  });
  final String     message;
  final IconData   icon;
  final VoidCallback onRetry;
  final String     label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        TextButton(onPressed: onRetry, child: Text(label)),
      ]),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.message,
    required this.onRetry,
    required this.label,
  });
  final String       message;
  final VoidCallback onRetry;
  final String       label;

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
