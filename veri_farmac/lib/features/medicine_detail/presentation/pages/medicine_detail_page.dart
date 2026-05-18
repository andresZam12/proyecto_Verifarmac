import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/models/history_entry_model.dart';
import '../../../scanner/domain/entities/scan_result.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/status_badge.dart';

const _kPrimary = Color(0xFF00478D);

class MedicineDetailPage extends ConsumerStatefulWidget {
  const MedicineDetailPage({super.key, required this.scanResult});
  final ScanResult scanResult;
  @override
  ConsumerState<MedicineDetailPage> createState() =>
      _MedicineDetailPageState();
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
    // Si el escáner detectó vencimiento físico, se prioriza sobre el estado
    // del registro INVIMA (que solo indica autorización sanitaria, no por lote).
    final status = widget.scanResult.status == 'vencido'
        ? 'vencido'
        : medicine.condition.label.toLowerCase();
    final entry = HistoryEntryModel(
      id:             widget.scanResult.id,
      medicineName:   medicine.name,
      sanitaryRecord: medicine.sanitaryRecord,
      status:         status,
      method:         widget.scanResult.method.name,
      createdAt:      widget.scanResult.scannedAt,
      laboratory:     medicine.laboratory,
      confidence:     widget.scanResult.confidence,
    );
    try {
      await HistoryLocalDataSource().save(entry);
      ref.read(dashboardProvider.notifier).load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);
    final l10n  = context.l10n;

    if (state.status == MedicineStatus.loaded && !_historySaved) {
      _saveToHistory(state.medicine!);
    }

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
                l10n.result,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textDark,
                ),
              ),
            ]),
          ),
        ),

        Expanded(
          child: switch (state.status) {
            MedicineStatus.loading => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: _kPrimary),
                  const SizedBox(height: 16),
                  Text(l10n.consultingInvima,
                      style: TextStyle(color: context.textSub)),
                ],
              ),
            ),
            MedicineStatus.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFBA1A1A), size: 52),
                    const SizedBox(height: 16),
                    Text(state.error ?? 'Error',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.textSub)),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => ref
                          .read(medicineProvider.notifier)
                          .loadByBarcode(_medicineId),
                      style: FilledButton.styleFrom(
                          backgroundColor: _kPrimary),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            MedicineStatus.notFound => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: context.pillBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.search_off_rounded,
                          color: _kPrimary, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.medicineNotFound,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.medicineNotFoundDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, color: context.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MedicineStatus.loaded => _Detail(
              medicine:          state.medicine!,
              l10n:              l10n,
              physicallyExpired: widget.scanResult.status == 'vencido',
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.medicine,
    required this.l10n,
    this.physicallyExpired = false,
  });
  final Medicine         medicine;
  final AppLocalizations l10n;
  final bool             physicallyExpired;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: [
              StatusBadge(condition: medicine.condition, large: true),
              const SizedBox(height: 16),
              Text(
                medicine.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ConfidenceBar(confidence: medicine.condition.isSafe ? 0.95 : 0.4),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Alerta de vencimiento físico detectado por OCR
        if (physicallyExpired) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.event_busy_rounded, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Producto físicamente vencido',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La fecha de vencimiento detectada en el empaque indica que este lote ya expiró. '
                    'El registro INVIMA mostrado refleja la autorización sanitaria del producto, '
                    'no la vigencia del lote específico.',
                    style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Recordatorio general para medicamentos vigentes (registro OK, pero verificar fecha física)
        if (medicine.condition == MedicineCondition.valid && !physicallyExpired) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'El registro INVIMA indica que este producto está autorizado para la venta en Colombia. '
                  'Verifica también la fecha de vencimiento física impresa en el empaque.',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Advertencia de medicamento no seguro (registro vencido/inválido/sospechoso)
        if (!medicine.condition.isSafe && !physicallyExpired) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_rounded,
                  color: Color(0xFFBA1A1A), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.unsafeMedicineWarning,
                  style: const TextStyle(
                    color: Color(0xFFBA1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],

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
            _InfoRow(label: l10n.activeIngredient,
                value: medicine.activeIngredient!),
          if (medicine.concentration != null)
            _InfoRow(label: l10n.concentration,
                value: medicine.concentration!),
          if (medicine.pharmaceuticalForm != null)
            _InfoRow(label: l10n.pharmaceuticalForm,
                value: medicine.pharmaceuticalForm!),
        ]),
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
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
          boxShadow: context.cardShadow(opacity: 0.06),
        ),
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1, indent: 16, endIndent: 16,
                color: context.dividerColor,
              ),
          ],
        ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: context.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
    );
  }
}
