// Pantalla de inicio con estadísticas y acceso rápido.
// TODO: mostrar gráfica donut, conteos y botón de escaneo rápido

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/offline_banner.dart';
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
    Future.microtask(() => ref.read(dashboardProvider.notifier).cargar());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Column(
        children: [
          // Banner de sin conexión
          const OfflineBanner(),

          Expanded(
            child: state.cargando
                ? const AppLoading()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Botón de escaneo rápido
                        QuickScanButton(
                          alPresionar: () => context.push(AppRoutes.scanner),
                        ),

                        const SizedBox(height: 28),

                        // Título de estadísticas
                        Text(
                          'Resumen de escaneos',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 16),

                        // Tarjetas de conteo
                        Row(
                          children: [
                            _TarjetaEstado(
                              etiqueta: 'Total',
                              cantidad: state.total,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _TarjetaEstado(
                              etiqueta: 'Vigentes',
                              cantidad: state.vigentes,
                              color: const Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 12),
                            _TarjetaEstado(
                              etiqueta: 'Vencidos',
                              cantidad: state.vencidos,
                              color: const Color(0xFFC62828),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Gráfica donut
                        Text(
                          'Distribución',
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
        ],
      ),
    );
  }
}

// Tarjeta pequeña con conteo por estado
class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({
    required this.etiqueta,
    required this.cantidad,
    required this.color,
  });

  final String etiqueta;
  final int    cantidad;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$cantidad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}