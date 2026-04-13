import 'package:flutter/material.dart';
import '../../domain/entities/medicine.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.condition, this.large = false});
  final MedicineCondition condition;
  final bool              large;

  @override
  Widget build(BuildContext context) {
    final color = _color(condition);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical:   large ? 8  : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icon(condition), size: large ? 18 : 14, color: color),
        SizedBox(width: large ? 8 : 5),
        Text(
          condition.label,
          style: TextStyle(
            fontSize: large ? 15 : 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ]),
    );
  }

  Color _color(MedicineCondition c) => switch (c) {
    MedicineCondition.valid      => const Color(0xFF2E7D32),
    MedicineCondition.expired    => const Color(0xFFC62828),
    MedicineCondition.invalid    => const Color(0xFFE65100),
    MedicineCondition.suspicious => const Color(0xFF6A1B9A),
    MedicineCondition.unknown    => const Color(0xFF546E7A),
  };

  IconData _icon(MedicineCondition c) => switch (c) {
    MedicineCondition.valid      => Icons.check_circle_rounded,
    MedicineCondition.expired    => Icons.cancel_rounded,
    MedicineCondition.invalid    => Icons.block_rounded,
    MedicineCondition.suspicious => Icons.warning_rounded,
    MedicineCondition.unknown    => Icons.help_rounded,
  };
}
