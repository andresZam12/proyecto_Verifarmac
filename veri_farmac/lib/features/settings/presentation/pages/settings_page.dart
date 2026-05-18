import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _kPrimary = Color(0xFF00478D);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n          = context.l10n;
    final currentTheme  = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final user          = Supabase.instance.client.auth.currentUser;
    final avatar        = user?.userMetadata?['avatar_url'] as String?;
    final metaName      = (user?.userMetadata?['full_name'] as String?
                        ?? user?.userMetadata?['name'] as String? ?? '').trim();
    final email         = user?.email
                        ?? ref.read(authProvider).localEmail
                        ?? '';
    final emailPrefix   = email.isNotEmpty ? email.split('@').first : '';
    final rawName       = metaName.isNotEmpty ? metaName : emailPrefix;
    final name          = rawName.isNotEmpty ? rawName : email;

    final themeLabel = switch (currentTheme) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark  => l10n.themeDark,
      _               => l10n.themeSystem,
    };
    final languageLabel =
        currentLocale?.languageCode == 'en' ? l10n.english : l10n.spanish;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(children: [

        _TopBar(title: l10n.settings),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [

              _ProfileCard(
                name:   name,
                avatar: avatar,
                onTap:  () => context.push(AppRoutes.settingsProfile),
                l10n:   l10n,
              ),
              const SizedBox(height: 28),

              _SectionLabel(l10n.account),
              const SizedBox(height: 8),
              _Card(children: [
                _Row(
                  icon:     Icons.person_outline_rounded,
                  title:    l10n.profile,
                  subtitle: l10n.viewEditProfile,
                  onTap:    () => context.push(AppRoutes.settingsProfile),
                ),
              ]),
              const SizedBox(height: 20),

              _SectionLabel(l10n.appearance),
              const SizedBox(height: 8),
              _Card(children: [
                _Row(
                  icon:     Icons.palette_outlined,
                  title:    l10n.themeLabel,
                  subtitle: themeLabel,
                  onTap:    () => context.push(AppRoutes.settingsTheme),
                ),
                const _CardDivider(),
                _Row(
                  icon:     Icons.language_rounded,
                  title:    l10n.language,
                  subtitle: languageLabel,
                  onTap:    () => context.push(AppRoutes.settingsLanguage),
                ),
              ]),
              const SizedBox(height: 20),

              _SectionLabel(l10n.about),
              const SizedBox(height: 8),
              _Card(children: [
                _Row(
                  icon:     Icons.info_outline_rounded,
                  title:    l10n.version,
                  subtitle: '1.0.0',
                  trailing: const SizedBox.shrink(),
                ),
              ]),
              const SizedBox(height: 20),

              const _Footer(),
            ],
          ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.textDark),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.dashboard),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textDark,
              letterSpacing: 0.2,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.avatar,
    required this.onTap,
    required this.l10n,
  });
  final String       name;
  final String?      avatar;
  final VoidCallback onTap;
  final dynamic      l10n;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'U';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
          boxShadow: context.cardShadow(opacity: 0.07),
        ),
        child: Row(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _kPrimary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatar != null
                  ? Image.network(
                      avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) =>
                          _AvatarFallback(initials: initials),
                    )
                  : _AvatarFallback(initials: initials),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.viewEditProfile,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSub,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.pillBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PERFIL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.pillBg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _kPrimary,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _kPrimary,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
        boxShadow: context.cardShadow(opacity: 0.06),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData      icon;
  final String        title;
  final String?       subtitle;
  final Widget?       trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: context.pillBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSub,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: context.textSub,
                size: 20,
              ),
        ]),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 0,
      color: context.dividerColor,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Text(
        'VERIFARMAC V1.0.0 · 2025 CLINICAL SYSTEMS',
        style: TextStyle(
          fontSize: 10,
          color: context.textSub.withValues(alpha: 0.5),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
