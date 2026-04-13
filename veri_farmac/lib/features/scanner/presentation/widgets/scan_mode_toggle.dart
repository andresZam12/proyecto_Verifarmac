// Toggle para cambiar entre modo Barcode y OCR.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

// Modos de escaneo disponibles
enum ScanMode { barcode, ocr }

// Toggle que permite cambiar entre escaneo por código de barras y por texto OCR.
class ScanModeToggle extends StatelessWidget {
  const ScanModeToggle({
    super.key,
    required this.currentMode,
    required this.onChange,
  });

  final ScanMode                currentMode;
  final ValueChanged<ScanMode>  onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            icon:       Icons.qr_code_scanner_rounded,
            label:      l10n.scanModeBarcode,
            isSelected: currentMode == ScanMode.barcode,
            onPress:    () => onChange(ScanMode.barcode),
          ),
          const SizedBox(width: 4),
          _ModeButton(
            icon:       Icons.text_fields_rounded,
            label:      l10n.scanModeOcr,
            isSelected: currentMode == ScanMode.ocr,
            onPress:    () => onChange(ScanMode.ocr),
          ),
        ],
      ),
    );
  }
}

// Botón individual del toggle
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPress,
  });

  final IconData     icon;
  final String       label;
  final bool         isSelected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
