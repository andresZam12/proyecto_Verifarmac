// Botón flotante para abrir el scanner directamente.
// TODO: implementar con FloatingActionButton y animación Hero

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

// Botón flotante grande para abrir el scanner directamente desde el dashboard.
class QuickScanButton extends StatelessWidget {
  const QuickScanButton({super.key, required this.alPresionar});
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: alPresionar,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text(
          'Escanear medicamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}