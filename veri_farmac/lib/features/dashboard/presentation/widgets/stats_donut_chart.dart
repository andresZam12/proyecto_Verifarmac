import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';

class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.total == 0) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.noScansYet)),
      );
    }
    return SizedBox(
      height: 200,
      child: Row(children: [
        Expanded(
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 50,
            sections: _sections(),
          )),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: const Color(0xFF2E7D32), label: l10n.filterValid,      count: state.valid),
            _LegendItem(color: const Color(0xFFC62828), label: l10n.filterExpired,    count: state.expired),
            _LegendItem(color: const Color(0xFFE65100), label: l10n.filterInvalid,    count: state.invalid),
            _LegendItem(color: const Color(0xFF6A1B9A), label: l10n.filterSuspicious, count: state.suspicious),
          ],
        ),
      ]),
    );
  }

  List<PieChartSectionData> _sections() => [
    if (state.valid      > 0) PieChartSectionData(value: state.valid.toDouble(),      color: const Color(0xFF2E7D32), title: '', radius: 30),
    if (state.expired    > 0) PieChartSectionData(value: state.expired.toDouble(),    color: const Color(0xFFC62828), title: '', radius: 30),
    if (state.invalid    > 0) PieChartSectionData(value: state.invalid.toDouble(),    color: const Color(0xFFE65100), title: '', radius: 30),
    if (state.suspicious > 0) PieChartSectionData(value: state.suspicious.toDouble(), color: const Color(0xFF6A1B9A), title: '', radius: 30),
  ];
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.count});
  final Color  color;
  final String label;
  final int    count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: $count', style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
