// Botón de "Continuar con Google" reutilizable.
// Muestra un spinner cuando está cargando.

import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPress,
    this.isLoading = false,
  });

  final VoidCallback onPress;
  final bool         isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPress,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de Google con sus colores oficiales
                  const _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Logo de Google dibujado con texto colorido
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4), // azul de Google
      ),
    );
  }
}
