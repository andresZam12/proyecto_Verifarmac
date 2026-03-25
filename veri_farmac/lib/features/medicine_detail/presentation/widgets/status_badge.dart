import 'package:flutter/material.dart';
import '../../domain/entities/medicine.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.estado, this.grande = false});
  final EstadoMedicamento estado;
  final bool              grande;

  @override
  Widget build(BuildContext context) {
    final color = _color(estado);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: grande ? 16 : 10, vertical: grande ? 8 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(grande ? 12 : 8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icono(estado), size: grande ? 18 : 14, color: color),
        SizedBox(width: grande ? 8 : 5),
        Text(estado.etiqueta, style: TextStyle(fontSize: grande ? 15 : 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Color _color(EstadoMedicamento e) => switch (e) {
    EstadoMedicamento.vigente     => const Color(0xFF2E7D32),
    EstadoMedicamento.vencido     => const Color(0xFFC62828),
    EstadoMedicamento.invalido    => const Color(0xFFE65100),
    EstadoMedicamento.sospechoso  => const Color(0xFF6A1B9A),
    EstadoMedicamento.desconocido => const Color(0xFF546E7A),
  };

  IconData _icono(EstadoMedicamento e) => switch (e) {
    EstadoMedicamento.vigente     => Icons.check_circle_rounded,
    EstadoMedicamento.vencido     => Icons.cancel_rounded,
    EstadoMedicamento.invalido    => Icons.block_rounded,
    EstadoMedicamento.sospechoso  => Icons.warning_rounded,
    EstadoMedicamento.desconocido => Icons.help_rounded,
  };
}
