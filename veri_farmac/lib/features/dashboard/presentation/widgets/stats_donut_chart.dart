// Gráfica donut con fl_chart para distribución de estados.
// TODO: implementar con PieChart de fl_chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/dashboard_provider.dart';

// Gráfica donut que muestra la distribución de estados de los escaneos.
// Usa fl_chart — widget avanzado requerido por la materia.
class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, muestra un mensaje
    if (state.total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sin escaneos aún')),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Gráfica donut
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _secciones(state),
              ),
            ),
          ),

          // Leyenda
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemLeyenda(color: const Color(0xFF2E7D32),
                  etiqueta: 'Vigentes', cantidad: state.vigentes),
              _ItemLeyenda(color: const Color(0xFFC62828),
                  etiqueta: 'Vencidos', cantidad: state.vencidos),
              _ItemLeyenda(color: const Color(0xFFE65100),
                  etiqueta: 'Inválidos', cantidad: state.invalidos),
              _ItemLeyenda(color: const Color(0xFF6A1B9A),
                  etiqueta: 'Sospechosos', cantidad: state.sospechosos),
            ],
          ),
        ],
      ),
    );
  }

  // Crea las secciones de la gráfica según las estadísticas
  List<PieChartSectionData> _secciones(DashboardState state) {
    return [
      if (state.vigentes > 0)
        PieChartSectionData(
          value: state.vigentes.toDouble(),
          color: const Color(0xFF2E7D32),
          title: '',
          radius: 30,
        ),
      if (state.vencidos > 0)
        PieChartSectionData(
          value: state.vencidos.toDouble(),
          color: const Color(0xFFC62828),
          title: '',
          radius: 30,
        ),
      if (state.invalidos > 0)
        PieChartSectionData(
          value: state.invalidos.toDouble(),
          color: const Color(0xFFE65100),
          title: '',
          radius: 30,
        ),
      if (state.sospechosos > 0)
        PieChartSectionData(
          value: state.sospechosos.toDouble(),
          color: const Color(0xFF6A1B9A),
          title: '',
          radius: 30,
        ),
    ];
  }
}

// Item de la leyenda con color, etiqueta y cantidad
class _ItemLeyenda extends StatelessWidget {
  const _ItemLeyenda({
    required this.color,
    required this.etiqueta,
    required this.cantidad,
  });

  final Color  color;
  final String etiqueta;
  final int    cantidad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$etiqueta: $cantidad',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}