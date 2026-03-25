// Tile de una entrada del historial.
// TODO: mostrar nombre, StatusBadge, fecha y opción de eliminar

import 'package:flutter/material.dart';

import '../../../../features/medicine_detail/domain/entities/medicine.dart';
import '../../../../features/medicine_detail/presentation/widgets/status_badge.dart';
import '../../domain/entities/history_entry.dart';

// Tile que muestra un escaneo guardado en el historial.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({
    super.key,
    required this.entrada,
    this.alPresionar,
    this.alEliminar,
  });

  final HistoryEntry  entrada;
  final VoidCallback? alPresionar;
  final VoidCallback? alEliminar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: alPresionar,
      leading: _IconoMetodo(metodo: entrada.metodo),
      title: Text(
        entrada.nombreMedicamento,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entrada.creadoEn.fechaRelativa,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge del estado
          StatusBadge(estado: Medicamento.parsearEstado(entrada.estado)),
          // Botón de eliminar
          if (alEliminar != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: Theme.of(context).colorScheme.error,
              onPressed: alEliminar,
            ),
        ],
      ),
    );
  }
}

// Ícono según el método de escaneo usado
class _IconoMetodo extends StatelessWidget {
  const _IconoMetodo({required this.metodo});
  final String metodo;

  @override
  Widget build(BuildContext context) {
    final icono = switch (metodo) {
      'ocr'    => Icons.text_fields_rounded,
      'visual' => Icons.image_search_rounded,
      _        => Icons.qr_code_scanner_rounded,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icono, size: 20,
        color: Theme.of(context).colorScheme.primary),
    );
  }
}

// Extensión para mostrar la fecha relativa
extension on DateTime {
  String get fechaRelativa {
    final hoy = DateTime.now();
    final diff = DateTime(hoy.year, hoy.month, hoy.day)
        .difference(DateTime(year, month, day))
        .inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '$day/$month/$year';
  }
}