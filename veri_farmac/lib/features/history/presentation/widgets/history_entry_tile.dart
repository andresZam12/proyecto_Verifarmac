// Tile que muestra un escaneo guardado en el historial.

import 'package:flutter/material.dart';
import '../../../../features/medicine_detail/domain/entities/medicine.dart';
import '../../../../features/medicine_detail/presentation/widgets/status_badge.dart';
import '../../domain/entities/history_entry.dart';

class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({
    super.key,
    required this.entry,
    this.onPress,
    this.onDelete,
  });

  final HistoryEntry  entry;
  final VoidCallback? onPress;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: _MethodIcon(method: entry.method),
      title: Text(
        entry.medicineName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.createdAt.relativeDate,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge del estado del medicamento
          StatusBadge(condition: Medicine.parseCondition(entry.status)),
          // Botón de eliminar
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

// Ícono según el método de escaneo usado
class _MethodIcon extends StatelessWidget {
  const _MethodIcon({required this.method});
  final String method;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      'ocr'    => Icons.text_fields_rounded,
      'visual' => Icons.image_search_rounded,
      _        => Icons.qr_code_scanner_rounded,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
    );
  }
}

// Extensión para mostrar la fecha relativa
extension on DateTime {
  String get relativeDate {
    final today = DateTime.now();
    final diff  = DateTime(today.year, today.month, today.day)
        .difference(DateTime(year, month, day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$day/$month/$year';
  }
}
