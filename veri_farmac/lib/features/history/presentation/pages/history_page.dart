import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/history_provider.dart';
import '../widgets/history_entry_tile.dart';

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
      appBar: AppBar(
        title: Text(l10n.history),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _StatusFilter(
            currentFilter: state.filter,
            onChange: (f) => ref.read(historyProvider.notifier).filterBy(f),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) { return AppLoading(message: l10n.loadingHistory); }
        if (state.error != null) {
          return AppErrorWidget(
            message: state.error!,
            onRetry: () => ref.read(historyProvider.notifier).load(),
          );
        }
        if (state.filteredEntries.isEmpty) {
          return AppEmptyState(
            title: l10n.noRecords,
            description: l10n.scannedMedicinesHere,
          );
        }
        return ListView.separated(
          itemCount: state.filteredEntries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final entry = state.filteredEntries[i];
            return HistoryEntryTile(
              entry: entry,
              onDelete: () => _confirmDelete(context, entry.id),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.confirmDeleteRecord),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).delete(id);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.currentFilter, required this.onChange});
  final String?               currentFilter;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      (label: l10n.all,             value: null),
      (label: l10n.filterValid,     value: 'vigente'),
      (label: l10n.filterExpired,   value: 'vencido'),
      (label: l10n.filterInvalid,   value: 'invalido'),
      (label: l10n.filterSuspicious,value: 'sospechoso'),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(f.label),
            selected: currentFilter == f.value,
            onSelected: (_) => onChange(f.value),
          ),
        )).toList(),
      ),
    );
  }
}
