import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../features/scanner/domain/entities/scan_result.dart';
import '../providers/history_provider.dart';
import '../widgets/history_entry_tile.dart';

const _kPrimary = Color(0xFF00478D);

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final l10n  = context.l10n;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(children: [

        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.textDark),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/dashboard'),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.history,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textDark,
                ),
              ),
              const Spacer(),
              if (state.entries.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Color(0xFFBA1A1A),
                  ),
                  tooltip: 'Eliminar todo',
                  onPressed: () => _confirmDeleteAll(context),
                ),
            ]),
          ),
        ),

        _FilterBar(
          currentFilter: state.filter,
          onChange: (f) => ref.read(historyProvider.notifier).filterBy(f),
        ),

        Expanded(
          child: Builder(builder: (context) {
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: _kPrimary),
                    const SizedBox(height: 16),
                    Text(l10n.loadingHistory,
                        style: TextStyle(color: context.textSub)),
                  ],
                ),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFBA1A1A), size: 48),
                    const SizedBox(height: 16),
                    Text(state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.textSub)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          ref.read(historyProvider.notifier).load(),
                      style: FilledButton.styleFrom(
                          backgroundColor: _kPrimary),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state.filteredEntries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: context.pillBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: _kPrimary, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noRecords,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.scannedMedicinesHere,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSub,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: state.filteredEntries.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final entry = state.filteredEntries[i];
                return HistoryEntryTile(
                  entry:    entry,
                  onDelete: () => _confirmDelete(context, entry.id),
                  onPress:  () => context.push(
                    AppRoutes.medicine,
                    extra: ScanResult(
                      id:             entry.id,
                      scannedValue:   entry.sanitaryRecord,
                      method:         _toScanMethod(entry.method),
                      scannedAt:      entry.createdAt,
                      confidence:     entry.confidence,
                      medicineName:   entry.medicineName,
                      sanitaryRecord: entry.sanitaryRecord,
                      status:         entry.status,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ]),
    );
  }

  ScanMethod _toScanMethod(String method) => switch (method) {
    'ocr'    => ScanMethod.ocr,
    'visual' => ScanMethod.visual,
    _        => ScanMethod.barcode,
  };

  void _confirmDeleteAll(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar todo el historial',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            '¿Eliminar todos los registros? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(color: context.textSub)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).deleteAll();
            },
            child: const Text('Eliminar todo',
                style: TextStyle(
                    color: Color(0xFFBA1A1A),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteRecord,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(l10n.confirmDeleteRecord),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(color: context.textSub)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).delete(id);
            },
            child: Text(l10n.delete,
                style: const TextStyle(
                    color: Color(0xFFBA1A1A),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.currentFilter, required this.onChange});
  final String?               currentFilter;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      (label: l10n.all,              value: null),
      (label: l10n.filterValid,      value: 'vigente'),
      (label: l10n.filterExpired,    value: 'vencido'),
      (label: l10n.filterInvalid,    value: 'invalido'),
      (label: l10n.filterSuspicious, value: 'sospechoso'),
    ];

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((f) {
          final isSelected = currentFilter == f.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChange(f.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? _kPrimary : context.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _kPrimary : context.dividerColor,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.textSub,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
