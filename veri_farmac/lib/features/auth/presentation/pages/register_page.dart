import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

const _kBg          = Color(0xFFF8F9FF);
const _kPrimary     = Color(0xFF00478D);
const _kPrimaryEnd  = Color(0xFF005EB8);
const _kTextDark    = Color(0xFF161C24);
const _kTextSub     = Color(0xFF424752);
const _kTextMuted   = Color(0xFF727783);
const _kInputBg     = Color(0xFFEEF4FF);
const _kPlaceholder = Color(0x99727783);
const _kError       = Color(0xFFBA1A1A);

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showPass        = false;
  bool _showConfirmPass = false;
  String? _nameError, _emailError, _passError, _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final conf  = _confirmPassCtrl.text;
    setState(() {
      _nameError    = name.isEmpty
          ? 'Ingresa tu nombre completo' : null;
      _emailError   = !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? 'Ingresa un email válido (ej: correo@gmail.com)' : null;
      _passError    = pass.length < 6           ? 'Mínimo 6 caracteres'          : null;
      _confirmError = pass != conf              ? 'Las contraseñas no coinciden' : null;
    });
    return _nameError == null && _emailError == null &&
           _passError == null && _confirmError == null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authProvider, (_, current) {
      if (current.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      } else if (current.status == AuthStatus.unauthenticated &&
          current.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.message!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _kPrimary,
          ),
        );
        context.go(AppRoutes.login);
      } else if (current.status == AuthStatus.error && current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _kError,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (logo) ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 8),
                          blurRadius: 10,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_rounded,
                          color: _kPrimary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.login),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: _kPrimary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa los datos para registrarte en Verifarmac.',
                style: TextStyle(
                  fontSize: 15,
                  color: _kTextSub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── Nombre completo ────────────────────────────────
              const _FieldLabel('NOMBRE COMPLETO'),
              const SizedBox(height: 8),
              _InputBox(
                controller: _nameCtrl,
                hint:       'Juan García',
                icon:       Icons.person_outline_rounded,
                errorText:  _nameError,
              ),
              const SizedBox(height: 20),

              // ── Email ──────────────────────────────────────────
              const _FieldLabel('CORREO ELECTRÓNICO'),
              const SizedBox(height: 8),
              _InputBox(
                controller:   _emailCtrl,
                hint:         'correo@ejemplo.com',
                icon:         Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText:    _emailError,
              ),
              const SizedBox(height: 20),

              // ── Contraseña ─────────────────────────────────────
              const _FieldLabel('CONTRASEÑA'),
              const SizedBox(height: 8),
              _InputBox(
                controller:  _passCtrl,
                hint:        '••••••••',
                icon:        Icons.lock_outline_rounded,
                obscureText: !_showPass,
                errorText:   _passError,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _showPass = !_showPass),
                  child: Icon(
                    _showPass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _kTextMuted,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Confirmar contraseña ───────────────────────────
              const _FieldLabel('CONFIRMAR CONTRASEÑA'),
              const SizedBox(height: 8),
              _InputBox(
                controller:  _confirmPassCtrl,
                hint:        '••••••••',
                icon:        Icons.lock_outline_rounded,
                obscureText: !_showConfirmPass,
                errorText:   _confirmError,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _showConfirmPass = !_showConfirmPass),
                  child: Icon(
                    _showConfirmPass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _kTextMuted,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Botón Registrarse ──────────────────────────────
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        if (_validate()) {
                          ref.read(authProvider.notifier).signUpWithEmail(
                            _nameCtrl.text.trim(),
                            _emailCtrl.text.trim(),
                            _passCtrl.text,
                          );
                        }
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kPrimary, _kPrimaryEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3300478D),
                        offset: Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Link a login ───────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.login),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: TextStyle(
                              fontSize: 14, color: _kTextSub),
                        ),
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                            fontSize: 14,
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: _kTextSub,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText  = false,
    this.errorText,
    this.suffixIcon,
  });
  final TextEditingController controller;
  final String                hint;
  final IconData              icon;
  final TextInputType?        keyboardType;
  final bool                  obscureText;
  final String?               errorText;
  final Widget?               suffixIcon;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _kInputBg,
            borderRadius: BorderRadius.circular(16),
            border: hasError
                ? Border.all(color: _kError, width: 1.5)
                : null,
          ),
          child: TextField(
            controller:   controller,
            keyboardType: keyboardType,
            obscureText:  obscureText,
            style: const TextStyle(fontSize: 16, color: _kTextDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: _kPlaceholder, fontSize: 16),
              prefixIcon: Icon(icon,
                  color: hasError ? _kError : _kTextMuted, size: 18),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
                fontSize: 12,
                color: _kError,
                fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}
