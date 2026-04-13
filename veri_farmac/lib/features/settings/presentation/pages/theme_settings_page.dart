// Pantalla para elegir tema: Light, Dark o Sistema.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n         = context.l10n;

    final options = [
      (mode: ThemeMode.system, icon: Icons.brightness_auto_rounded, label: l10n.themeSystem),
      (mode: ThemeMode.light,  icon: Icons.light_mode_rounded,       label: l10n.themeLight),
      (mode: ThemeMode.dark,   icon: Icons.dark_mode_rounded,        label: l10n.themeDark),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.themeLabel)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: options.map((option) {
            final isSelected = currentTheme == option.mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .changeTheme(option.mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 0.5,
                    ),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                  ),
                  child: Row(children: [
                    Icon(option.icon, color: isSelected ? AppColors.primary : null),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
