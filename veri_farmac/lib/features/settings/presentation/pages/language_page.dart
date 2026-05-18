import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

const _kPrimary = Color(0xFF00478D);

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final l10n          = context.l10n;

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
                l10n.language,
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
                  l10n.chooseLanguage,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentLocale?.languageCode == 'en'
                      ? 'Select your preferred language'
                      : 'Selecciona tu idioma preferido',
                  style: TextStyle(fontSize: 14, color: context.textSub),
                ),
                const SizedBox(height: 32),

                _LangOption(
                  flag:       '🇨🇴',
                  name:       l10n.spanish,
                  isSelected: currentLocale?.languageCode != 'en',
                  onPress: () {
                    ref
                        .read(localeNotifierProvider.notifier)
                        .changeLocale(const Locale('es'));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _LangOption(
                  flag:       '🇺🇸',
                  name:       l10n.english,
                  isSelected: currentLocale?.languageCode == 'en',
                  onPress: () {
                    ref
                        .read(localeNotifierProvider.notifier)
                        .changeLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onPress,
  });
  final String       flag;
  final String       name;
  final bool         isSelected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9EEF9) : context.cardColor,
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
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
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
              color: isSelected ? _kPrimary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _kPrimary : context.dividerColor,
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
    );
  }
}
