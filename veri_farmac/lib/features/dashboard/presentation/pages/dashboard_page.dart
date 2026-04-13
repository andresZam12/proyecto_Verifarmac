import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/quick_scan_button.dart';
import '../widgets/stats_donut_chart.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final l10n  = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        // Botón de ajustes en el AppBar — accede a todas las configuraciones
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(children: [
        const OfflineBanner(),
        Expanded(
          child: state.isLoading
              ? const AppLoading()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón principal de escaneo
                      QuickScanButton(
                        onPress: () => context.push(AppRoutes.scanner),
                      ),
                      const SizedBox(height: 28),

                      // Tarjetas de resumen
                      Text(
                        l10n.scanSummary,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        _StatusCard(
                          label: l10n.total,
                          count: state.total,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatusCard(
                          label: l10n.valid,
                          count: state.valid,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 12),
                        _StatusCard(
                          label: l10n.expired,
                          count: state.expired,
                          color: const Color(0xFFC62828),
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Gráfica de distribución
                      Text(
                        l10n.distribution,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: StatsDonutChart(state: state),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.count, required this.color});
  final String label;
  final int    count;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ]),
      ),
    );
  }
}
