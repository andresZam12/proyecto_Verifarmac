import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
    Future.microtask(() => ref.read(mapProvider.notifier).load());
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

    ref.listen(mapProvider, (prev, next) {
      if (next.position != null && prev?.position == null) {
        _mapController.move(
          LatLng(next.position!.latitude, next.position!.longitude),
          14,
        );
      }
    });

    final lat = state.position?.latitude  ?? _pastoCenterLat;
    final lng = state.position?.longitude ?? _pastoCenterLng;

    final markers = [
      ...PharmacyMarker.create(
        pharmacies: state.pharmacies,
        onPress: (name) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(name))),
      ),
      if (state.position != null)
        PharmacyMarker.userLocation(lat, lng),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyPharmacies),
        actions: [
          if (!state.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  state.pharmacies.isEmpty
                      ? 'Sin resultados'
                      : '${state.pharmacies.length} encontradas',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: Stack(children: [
        // ── Mapa siempre visible ───────────────────────────────
        FlutterMap(
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
            MarkerLayer(markers: markers),
          ],
        ),

        // ── Indicador de carga sobre el mapa ──────────────────
        if (state.isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.gettingLocation),
                  ]),
                ),
              ),
            ),
          ),

        // ── Sin resultados ────────────────────────────────────
        if (!state.isLoading && state.pharmacies.isEmpty)
          Positioned(
            top: 12, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'No se encontraron farmacias en esta zona',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),

        // ── Permiso de ubicación denegado ─────────────────────
        if (state.permissionDenied)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(children: [
                const Icon(Icons.location_off_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.locationPermissionNeeded,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(mapProvider.notifier).load(),
                  child: Text(l10n.allowLocation),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
