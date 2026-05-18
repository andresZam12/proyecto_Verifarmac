import 'package:flutter/material.dart';
import 'package:veri_farmac/l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Size get screenSize => MediaQuery.sizeOf(this);
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // ── Colores adaptativos (light / dark) ──────────────────────
  //
  // Dark palette: azul marino profundo, inspirado en apps premium
  // (Linear, Vercel, GitHub dark). Cada capa es claramente más
  // clara que la anterior → jerarquía visual real.
  //
  Color get bgColor      => isDarkMode ? const Color(0xFF0D1017) : const Color(0xFFF8F9FF);
  Color get cardColor    => isDarkMode ? const Color(0xFF171C26) : Colors.white;
  Color get textDark     => isDarkMode ? const Color(0xFFF1F5FF) : const Color(0xFF161C24);
  Color get textSub      => isDarkMode ? const Color(0xFF8892A4) : const Color(0xFF424752);
  Color get pillBg       => isDarkMode ? const Color(0xFF1E2535) : const Color(0xFFE9EEF9);
  Color get inputBg      => isDarkMode ? const Color(0xFF1A2030) : const Color(0xFFEEF4FF);
  Color get scanItemBg   => isDarkMode ? const Color(0xFF171C26) : const Color(0xFFEEF4FF);
  Color get dividerColor => isDarkMode ? const Color(0xFF252D3D) : const Color(0xFFF0F0F5);
  Color get cardBorder   => isDarkMode ? const Color(0xFF2A3347) : Colors.transparent;
  Color get helpBg       => isDarkMode ? const Color(0xFF0D1D36) : const Color(0xFFD6E3FF);
  Color get helpTextDark => isDarkMode ? const Color(0xFFF1F5FF) : const Color(0xFF001B3D);
  Color get helpTextBlue => isDarkMode ? const Color(0xFF79B8FF) : const Color(0xFF00468C);
  Color get primaryColor => isDarkMode ? const Color(0xFF5BA3FF) : const Color(0xFF00478D);
  // Sombras adaptativas: en dark mode usa negro con más opacidad
  List<BoxShadow> cardShadow({double opacity = 0.08}) => isDarkMode
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
      : [BoxShadow(color: const Color(0xFF00478D).withValues(alpha: opacity), blurRadius: 12, offset: const Offset(0, 4))];

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
