import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../providers/dashboard_provider.dart';

class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.total == 0) return const SizedBox(height: 200, child: Center(child: Text('Sin escaneos aún')));
    return SizedBox(
      height: 200,
      child: Row(children: [
        Expanded(child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 50, sections: _secciones()))),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ItemLeyenda(color: const Color(0xFF2E7D32), etiqueta: 'Vigentes',    cantidad: state.vigentes),
          _ItemLeyenda(color: const Color(0xFFC62828), etiqueta: 'Vencidos',    cantidad: state.vencidos),
          _ItemLeyenda(color: const Color(0xFFE65100), etiqueta: 'Inválidos',   cantidad: state.invalidos),
          _ItemLeyenda(color: const Color(0xFF6A1B9A), etiqueta: 'Sospechosos', cantidad: state.sospechosos),
        ]),
      ]),
    );
  }

  List<PieChartSectionData> _secciones() => [
    if (state.vigentes > 0)    PieChartSectionData(value: state.vigentes.toDouble(),    color: const Color(0xFF2E7D32), title: '', radius: 30),
    if (state.vencidos > 0)    PieChartSectionData(value: state.vencidos.toDouble(),    color: const Color(0xFFC62828), title: '', radius: 30),
    if (state.invalidos > 0)   PieChartSectionData(value: state.invalidos.toDouble(),   color: const Color(0xFFE65100), title: '', radius: 30),
    if (state.sospechosos > 0) PieChartSectionData(value: state.sospechosos.toDouble(), color: const Color(0xFF6A1B9A), title: '', radius: 30),
  ];
}

class _ItemLeyenda extends StatelessWidget {
  const _ItemLeyenda({required this.color, required this.etiqueta, required this.cantidad});
  final Color color; final String etiqueta; final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$etiqueta: $cantidad', style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
