import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

const _kPrimary = Color(0xFF00478D);

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n         = context.l10n;

    final options = [
      (
        mode:  ThemeMode.system,
        icon:  Icons.brightness_auto_rounded,
        label: l10n.themeSystem,
      ),
      (
        mode:  ThemeMode.light,
        icon:  Icons.light_mode_rounded,
        label: l10n.themeLight,
      ),
      (
        mode:  ThemeMode.dark,
        icon:  Icons.dark_mode_rounded,
        label: l10n.themeDark,
      ),
    ];

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
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.themeLabel,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appearance,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.themeLabel,
                  style: TextStyle(fontSize: 14, color: context.textSub),
                ),
                const SizedBox(height: 32),

                ...options.map((opt) {
                  final isSelected = currentTheme == opt.mode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .changeTheme(opt.mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE9EEF9)
                              : context.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _kPrimary : context.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _kPrimary
                                  : context.pillBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              opt.icon,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : context.textSub,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? _kPrimary : context.textDark,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _kPrimary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _kPrimary
                                    : context.dividerColor,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                        ]),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
