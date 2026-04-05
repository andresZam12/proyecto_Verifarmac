import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme  = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final l10n          = context.l10n;

    final themeLabel = switch (currentTheme) {
      ThemeMode.light  => l10n.themeLight,
      ThemeMode.dark   => l10n.themeDark,
      _                => l10n.themeSystem,
    };
    final languageLabel =
        currentLocale?.languageCode == 'en' ? l10n.english : l10n.spanish;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(children: [

        // ─── Cuenta ────────────────────────────────────────────
        _Section(title: l10n.account),
        SettingsTile(
          icon:     Icons.person_outline_rounded,
          title:    l10n.profile,
          subtitle: l10n.viewEditProfile,
          onPress:  () => context.push(AppRoutes.settingsProfile),
        ),

        const Divider(height: 1),

        // ─── Apariencia ────────────────────────────────────────
        _Section(title: l10n.appearance),
        SettingsTile(
          icon:     Icons.palette_outlined,
          title:    l10n.themeLabel,
          subtitle: themeLabel,
          onPress:  () => context.push(AppRoutes.settingsTheme),
        ),
        SettingsTile(
          icon:     Icons.language_rounded,
          title:    l10n.language,
          subtitle: languageLabel,
          onPress:  () => context.push(AppRoutes.settingsLanguage),
        ),

        const Divider(height: 1),

        // ─── Acerca de ─────────────────────────────────────────
        _Section(title: l10n.about),
        SettingsTile(
          icon:     Icons.info_outline_rounded,
          title:    l10n.version,
          subtitle: '1.0.0',
          trailing: const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
