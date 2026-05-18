import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../scanner/domain/entities/scan_result.dart';
import '../providers/dashboard_provider.dart';

// ── Tokens de color fijos (no cambian con el tema) ────────────────────────────
const _kPrimary            = Color(0xFF00478D);
// Tarjeta verde
const _kGreenCardBg        = Color(0x4D90F4B7);
const _kGreenCardBorder    = Color(0x1A006D41);
const _kGreenVerifiedBadge = Color(0xFF77DA9F);
const _kGreenCount         = Color(0xFF007144);
const _kGreenSubLabel      = Color(0xB2007144);
const _kGreenBadgeBg       = Color(0x1A006D41);
const _kGreenBadgeText     = Color(0xFF006D41);
// Tarjeta roja
const _kRedText            = Color(0xFF94001F);
const _kRedBadgeBg         = Color(0x1A94001F);
// Tarjeta naranja (vencido)
const _kOrangeCardBg       = Color(0x1AE65100);
const _kOrangeCardBorder   = Color(0x1AE65100);
const _kOrangeText         = Color(0xFFBF360C);
const _kOrangeSubLabel     = Color(0xB2BF360C);
// Tarjeta morada (sospechoso)
const _kPurpleCardBg       = Color(0x1A6A1B9A);
const _kPurpleCardBorder   = Color(0x1A6A1B9A);
const _kPurpleText         = Color(0xFF6A1B9A);
const _kPurpleSubLabel     = Color(0xB26A1B9A);
// Tarjeta gris (desconocido)
const _kGrayCardBg         = Color(0x1A9E9E9E);
const _kGrayCardBorder     = Color(0x1A757575);
const _kGrayText           = Color(0xFF616161);
const _kGraySubLabel       = Color(0xB2616161);

// ─────────────────────────────────────────────────────────────────────────────

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).load();
      ref.read(historyProvider.notifier).load();
    });
  }

  String _firstName() {
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['full_name'] as String? ?? '').trim();
    if (name.isNotEmpty) return name.split(' ').first;
    final email = user?.email ?? ref.read(authProvider).localEmail ?? '';
    final username = email.split('@').first;
    return username.isNotEmpty ? username : 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final dash      = ref.watch(dashboardProvider);
    final hist      = ref.watch(historyProvider);
    final l10n      = context.l10n;
    final firstName = _firstName();

    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const _BottomNavBar(),
      body: Stack(children: [
        Positioned(
          right: -20,
          bottom: 60,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/mascot.png',
                width: 380,
              ),
            ),
          ),
        ),
        Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: dash.isLoading
                  ? const AppLoading()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopBar(l10n: l10n),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _WelcomeSection(firstName: firstName, l10n: l10n),
                                const SizedBox(height: 32),
                                _BentoGrid(dash: dash, l10n: l10n),
                                const SizedBox(height: 32),
                                _QuickScanCard(l10n: l10n),
                                const SizedBox(height: 32),
                                _RecentScansSection(
                                  entries:    hist.entries.take(3).toList(),
                                  l10n:       l10n,
                                  onClearAll: hist.entries.isEmpty
                                      ? null
                                      : () => ref.read(historyProvider.notifier).deleteAll(),
                                ),
                                const SizedBox(height: 32),
                                _HelpSection(l10n: l10n),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ]),
    );
  }
}

// ─── TopBar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: context.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: _kPrimary, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Verifarmac',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: _kPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => context.push(AppRoutes.settings),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.settings_rounded,
                  color: context.textDark,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Welcome Section ──────────────────────────────────────────────────────────

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.firstName, required this.l10n});
  final String           firstName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isEn     = Localizations.localeOf(context).languageCode == 'en';
    final greeting = isEn ? 'Hello, $firstName' : 'Hola, $firstName';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  color: context.textDark,
                  letterSpacing: -0.75,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.pharmacySummary,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: context.textSub,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/images/mascot.png',
          height: 100,
          width:  100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox(width: 100, height: 100),
        ),
      ],
    );
  }
}

// ─── Bento Grid ───────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.dash, required this.l10n});
  final DashboardState   dash;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainSummaryCard(total: dash.total, l10n: l10n),
        const SizedBox(height: 16),
        // Fila 1: Verificados y Desconocido
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MiniStatCard(
                icon:       Icons.check_circle_rounded,
                iconColor:  _kGreenVerifiedBadge,
                badgeLabel: l10n.verified.toUpperCase(),
                badgeColor: _kGreenVerifiedBadge,
                count:      dash.valid,
                countColor: _kGreenCount,
                subLabel:   'Vigentes',
                subColor:   _kGreenSubLabel,
                bgColor:    _kGreenCardBg,
                border:     _kGreenCardBorder,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MiniStatCard(
                icon:       Icons.device_unknown_rounded,
                iconColor:  _kGrayText,
                badgeLabel: 'DESCONOCIDO',
                badgeColor: _kGrayText,
                count:      dash.unknown,
                countColor: _kGrayText,
                subLabel:   'Desconocido',
                subColor:   _kGraySubLabel,
                bgColor:    _kGrayCardBg,
                border:     _kGrayCardBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Fila 2: Vencidos y Sospechosos
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MiniStatCard(
                icon:       Icons.timer_off_rounded,
                iconColor:  _kOrangeText,
                badgeLabel: l10n.filterExpired.toUpperCase(),
                badgeColor: _kOrangeText,
                count:      dash.expired,
                countColor: _kOrangeText,
                subLabel:   l10n.filterExpired,
                subColor:   _kOrangeSubLabel,
                bgColor:    _kOrangeCardBg,
                border:     _kOrangeCardBorder,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MiniStatCard(
                icon:       Icons.help_outline_rounded,
                iconColor:  _kPurpleText,
                badgeLabel: l10n.filterSuspicious.toUpperCase(),
                badgeColor: _kPurpleText,
                count:      dash.problematic,
                countColor: _kPurpleText,
                subLabel:   l10n.filterSuspicious,
                subColor:   _kPurpleSubLabel,
                bgColor:    _kPurpleCardBg,
                border:     _kPurpleCardBorder,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MainSummaryCard extends StatelessWidget {
  const _MainSummaryCard({required this.total, required this.l10n});
  final int              total;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: context.cardBorder),
        boxShadow: context.cardShadow(),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -32,
            right: -32,
            child: SizedBox(
              width: 128,
              height: 128,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x0D00478D),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalScans,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: _kPrimary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$total',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    color: context.textDark,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.badgeLabel,
    required this.badgeColor,
    required this.count,
    required this.countColor,
    required this.subLabel,
    required this.subColor,
    required this.bgColor,
    required this.border,
  });

  final IconData icon;
  final Color    iconColor;
  final String   badgeLabel;
  final Color    badgeColor;
  final int      count;
  final Color    countColor;
  final String   subLabel;
  final Color    subColor;
  final Color    bgColor;
  final Color    border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(
                badgeLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: badgeColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 30,
              color: countColor,
              height: 1.2,
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Scan Card ──────────────────────────────────────────────────────────

class _QuickScanCard extends StatelessWidget {
  const _QuickScanCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3300478D),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x3300478D),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.newVerification,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.newVerificationDesc,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFFC8DAFF),
                    height: 1.63,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.push(AppRoutes.scanner),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 20),
                    blurRadius: 25,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 8),
                    blurRadius: 10,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: _kPrimary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.scan,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent Scans Section ─────────────────────────────────────────────────────

class _RecentScansSection extends StatelessWidget {
  const _RecentScansSection({
    required this.entries,
    required this.l10n,
    this.onClearAll,
  });
  final List<HistoryEntry>   entries;
  final AppLocalizations      l10n;
  final VoidCallback?         onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                l10n.recentScans,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: context.textDark,
                ),
              ),
              const Spacer(),
              if (onClearAll != null)
                GestureDetector(
                  onTap: onClearAll,
                  child: Container(
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_sweep_rounded,
                        size: 16, color: Color(0xFFBA1A1A)),
                  ),
                ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.history),
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: context.scanItemBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                l10n.noRecentScans,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: context.textSub,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _ScanItem(
                  entry: entries[i],
                  index: i + 1,
                  l10n:  l10n,
                  onTap: () => context.push(
                    AppRoutes.medicine,
                    extra: ScanResult(
                      id:             entries[i].id,
                      scannedValue:   entries[i].sanitaryRecord,
                      method:         _toScanMethod(entries[i].method),
                      scannedAt:      entries[i].createdAt,
                      confidence:     entries[i].confidence,
                      medicineName:   entries[i].medicineName,
                      sanitaryRecord: entries[i].sanitaryRecord,
                      status:         entries[i].status,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  ScanMethod _toScanMethod(String method) => switch (method) {
    'ocr'    => ScanMethod.ocr,
    'visual' => ScanMethod.visual,
    _        => ScanMethod.barcode,
  };
}

class _ScanItem extends StatelessWidget {
  const _ScanItem({
    required this.entry,
    required this.index,
    required this.l10n,
    this.onTap,
  });
  final HistoryEntry     entry;
  final int              index;
  final AppLocalizations l10n;
  final VoidCallback?    onTap;

  bool get _isLegal => entry.status == 'vigente';

  String _timeAgo(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (diff.inMinutes < 1)  return isEn ? 'Just now' : 'Ahora';
    if (diff.inMinutes < 60) return isEn ? '${diff.inMinutes}m ago' : 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24)   return isEn ? '${diff.inHours}h ago' : 'Hace ${diff.inHours}h';
    if (diff.inDays == 1)    return isEn ? 'Yesterday' : 'Ayer';
    return isEn ? '${diff.inDays}d ago' : 'Hace ${diff.inDays}d';
  }

  String _scanDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final badgeBg   = _isLegal ? _kGreenBadgeBg  : _kRedBadgeBg;
    final badgeText = _isLegal ? _kGreenBadgeText : _kRedText;
    final badge     = _isLegal ? 'VIGENTE'        : l10n.alertBadge;
    final iconColor = _isLegal ? _kGreenCount     : _kRedText;
    final icon      = _isLegal
        ? Icons.medication_rounded
        : Icons.medication_liquid_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.scanItemBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escaneo #$index',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: context.textDark,
                    ),
                  ),
                  Text(
                    '${_scanDate(entry.createdAt)} · ${_timeAgo(context, entry.createdAt)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: context.textSub,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: badgeText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Help Section ─────────────────────────────────────────────────────────────

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.helpBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.doubtAboutProduct,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: context.helpTextDark,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            l10n.helpSectionDesc,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: context.helpTextBlue,
              height: 1.63,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push(AppRoutes.map),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.consultMap,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.map_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.home.toUpperCase(),
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.map_rounded,
                label: l10n.map.toUpperCase(),
                onTap: () => context.go(AppRoutes.map),
              ),
              _NavItem(
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.scan.toUpperCase(),
                onTap: () => context.go(AppRoutes.scanner),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.profile.toUpperCase(),
                onTap: () => context.go(AppRoutes.settingsProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         isActive;

  @override
  Widget build(BuildContext context) {
    const activeColor  = _kPrimary;
    final activePillBg = context.pillBg;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activePillBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : context.textSub,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : context.textSub,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
