import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/models/history_entry_model.dart';
import '../../../scanner/domain/entities/scan_result.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/status_badge.dart';

class MedicineDetailPage extends ConsumerStatefulWidget {
  const MedicineDetailPage({super.key, required this.scanResult});
  final ScanResult scanResult;
  @override
  ConsumerState<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends ConsumerState<MedicineDetailPage> {
  bool _historySaved = false;

  String get _medicineId =>
      widget.scanResult.sanitaryRecord ?? widget.scanResult.scannedValue;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(medicineProvider.notifier).loadByBarcode(_medicineId),
    );
  }

  Future<void> _saveToHistory(Medicine medicine) async {
    if (_historySaved) return;
    _historySaved = true;
    final entry = HistoryEntryModel(
      id:             widget.scanResult.id,
      medicineName:   medicine.name,
      sanitaryRecord: medicine.sanitaryRecord,
      status:         medicine.condition.label.toLowerCase(),
      method:         widget.scanResult.method.name,
      createdAt:      widget.scanResult.scannedAt,
      laboratory:     medicine.laboratory,
      confidence:     widget.scanResult.confidence,
    );
    try {
      await HistoryLocalDataSource().save(entry);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);
    final l10n  = context.l10n;

    // Guardar en historial la primera vez que carga exitosamente
    if (state.status == MedicineStatus.loaded && !_historySaved) {
      _saveToHistory(state.medicine!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.result)),
      body: switch (state.status) {
        MedicineStatus.loading    => AppLoading(message: l10n.consultingInvima),
        MedicineStatus.error      => AppErrorWidget(
            message: state.error ?? 'Error',
            onRetry: () => ref
                .read(medicineProvider.notifier)
                .loadByBarcode(_medicineId),
          ),
        MedicineStatus.notFound   => AppEmptyState(
            title:       l10n.medicineNotFound,
            description: l10n.medicineNotFoundDesc,
          ),
        MedicineStatus.loaded     => _Detail(medicine: state.medicine!, l10n: l10n),
        _                         => const SizedBox.shrink(),
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.medicine, required this.l10n});
  final Medicine          medicine;
  final AppLocalizations  l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: StatusBadge(condition: medicine.condition, large: true)),
        const SizedBox(height: 20),
        Text(
          medicine.name,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        const ConfidenceBar(confidence: 0.95),
        const SizedBox(height: 24),
        _InfoSection(title: l10n.sanitaryRecord, children: [
          _InfoRow(label: l10n.code,       value: medicine.sanitaryRecord),
          _InfoRow(label: l10n.status,     value: medicine.condition.label),
          _InfoRow(label: l10n.laboratory, value: medicine.laboratory),
          if (medicine.holder != null)
            _InfoRow(label: l10n.holder,   value: medicine.holder!),
        ]),
        const SizedBox(height: 16),
        _InfoSection(title: l10n.medicineInfo, children: [
          if (medicine.activeIngredient != null)
            _InfoRow(label: l10n.activeIngredient,   value: medicine.activeIngredient!),
          if (medicine.concentration != null)
            _InfoRow(label: l10n.concentration,      value: medicine.concentration!),
          if (medicine.pharmaceuticalForm != null)
            _InfoRow(label: l10n.pharmaceuticalForm, value: medicine.pharmaceuticalForm!),
        ]),
        const SizedBox(height: 24),
        if (!medicine.condition.isSafe)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.warning_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.unsafeMedicineWarning,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});
  final String       title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      const SizedBox(height: 10),
      Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(children: children),
        ),
      ),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}
