import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Quick access to the current theme
  ThemeData get theme => Theme.of(this);

  // Quick access to theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;

  // Whether dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  // Shows a quick snackbar
  // Example: context.showMessage('Saved successfully')
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
