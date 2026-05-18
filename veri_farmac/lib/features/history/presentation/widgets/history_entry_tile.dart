import 'package:flutter/material.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/medicine_detail/domain/entities/medicine.dart';
import '../../../../features/medicine_detail/presentation/widgets/status_badge.dart';
import '../../domain/entities/history_entry.dart';

const _kPrimary = Color(0xFF00478D);

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

  String _relativeDate(BuildContext context) {
    final l10n  = context.l10n;
    final today = DateTime.now();
    final diff  = DateTime(today.year, today.month, today.day)
        .difference(DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day))
        .inDays;
    final fullDate =
        '${entry.createdAt.day.toString().padLeft(2, '0')}/'
        '${entry.createdAt.month.toString().padLeft(2, '0')}/'
        '${entry.createdAt.year} '
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:'
        '${entry.createdAt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return '${l10n.today} · $fullDate';
    if (diff == 1) return '${l10n.yesterday} · $fullDate';
    return fullDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
          boxShadow: context.cardShadow(opacity: 0.06),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.pillBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _methodIcon(entry.method),
              size: 20,
              color: _kPrimary,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.medicineName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _relativeDate(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSub,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          StatusBadge(condition: Medicine.parseCondition(entry.status)),

          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: Color(0xFFBA1A1A),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  IconData _methodIcon(String method) => switch (method) {
    'ocr'    => Icons.text_fields_rounded,
    'visual' => Icons.image_search_rounded,
    _        => Icons.qr_code_scanner_rounded,
  };
}
