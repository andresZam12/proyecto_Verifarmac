import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

const _kPrimary       = Color(0xFF00478D);
const _kGreen         = Color(0xFF006D41);
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
    final state    = ref.watch(mapProvider);
    final l10n     = context.l10n;
    final selected = state.selectedHospital;
    final pos      = state.position;

    // Centrar en ubicación real con zoom cercano (post-frame para evitar NaN)
    ref.listen(mapProvider, (prev, next) {
      if (next.position != null && prev?.position == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(
              LatLng(next.position!.latitude, next.position!.longitude),
              16,
            );
          }
        });
      }
    });

    final markers = [
      ...HospitalMarker.create(
        hospitals: state.hospitals,
        onPress:   (h) => ref.read(mapProvider.notifier).selectHospital(h),
      ),
      if (pos != null)
        _userLocationMarker(pos.latitude, pos.longitude),
    ];

    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const _BottomNavBar(),
      body: GestureDetector(
        onTap: selected != null
            ? () => ref.read(mapProvider.notifier).selectHospital(null)
            : null,
        behavior: HitTestBehavior.translucent,
        child: Stack(children: [

          // ── Mapa ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_pastoCenterLat, _pastoCenterLng),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.verifarmac.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // ── Barra superior flotante ────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.dashboard),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.pillBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: _kPrimary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.hospitalsTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.textDark,
                          ),
                        ),
                        Text(
                          state.isLoading
                              ? 'Buscando clínicas...'
                              : state.hospitals.isEmpty
                                  ? 'Sin resultados cercanos'
                                  : '${state.hospitals.length} clínicas encontradas',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kPrimary),
                    )
                  else
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          color: Colors.white, size: 18),
                    ),
                ]),
              ),
            ),
          ),

          // ── Card detalle hospital ──────────────────────────────
          if (selected != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _HospitalCard(
                hospital: selected,
                l10n: l10n,
                onClose: () =>
                    ref.read(mapProvider.notifier).selectHospital(null),
              ),
            ),
        ]),
      ),
    );
  }

  Marker _userLocationMarker(double lat, double lng) {
    return Marker(
      point: LatLng(lat, lng),
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: _kPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hospital Detail Card ─────────────────────────────────────────────────────

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({
    required this.hospital,
    required this.l10n,
    required this.onClose,
  });
  final HospitalData hospital;
  final dynamic      l10n;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top:   BorderSide(color: context.cardBorder),
          left:  BorderSide(color: context.cardBorder),
          right: BorderSide(color: context.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CLÍNICA FARMACÉUTICA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: _kGreen, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.openStatus,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            hospital.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hospital.address,
            style: TextStyle(fontSize: 13, color: context.textSub),
          ),
          const SizedBox(height: 10),
          Text(
            hospital.description,
            style: TextStyle(
              fontSize: 13,
              color: context.textSub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1'
                  '&destination=${hospital.lat},${hospital.lng}'
                  '&travelmode=driving',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: Text(
                l10n.getRoute,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon:  Icons.home_rounded,
                label: l10n.home.toUpperCase(),
                onTap: () => context.go(AppRoutes.dashboard),
              ),
              _NavItem(
                icon:     Icons.map_rounded,
                label:    l10n.map.toUpperCase(),
                isActive: true,
                onTap:    () {},
              ),
              _NavItem(
                icon:  Icons.qr_code_scanner_rounded,
                label: l10n.scan.toUpperCase(),
                onTap: () => context.go(AppRoutes.scanner),
              ),
              _NavItem(
                icon:  Icons.person_rounded,
                label: l10n.profile.toUpperCase(),
                onTap: () => context.go(AppRoutes.settingsProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         isActive;

  @override
  Widget build(BuildContext context) {
    const activeColor  = _kPrimary;
    final activePillBg = context.pillBg;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activePillBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: isActive ? activeColor : context.textSub, size: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : context.textSub,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
