import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

// ── Tokens de color del diseño Figma ─────────────────────────────────────────
const _kBg          = Color(0xFFF8F9FF);
const _kPrimary     = Color(0xFF00478D);
const _kPrimaryEnd  = Color(0xFF005EB8);
const _kTextDark    = Color(0xFF161C24);
const _kTextSub     = Color(0xFF424752);
const _kTextMuted   = Color(0xFF727783);
const _kInputBg     = Color(0xFFEEF4FF);
const _kBorder      = Color(0xFFC2C6D4);
const _kPlaceholder = Color(0x99727783); // rgba(114,119,131,0.6)

// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword   = false;
  bool _rememberDevice = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showForgotDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(fontSize: 14, color: _kTextSub, height: 1.45),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _kInputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15, color: _kTextDark),
                decoration: const InputDecoration(
                  hintText: 'correo@ejemplo.com',
                  hintStyle: TextStyle(color: _kPlaceholder),
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: _kTextMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: _kTextMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = emailCtrl.text.trim();
              Navigator.pop(ctx);
              if (email.isEmpty) return;
              await ref.read(authProvider.notifier).resetPassword(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Si el correo existe, recibirás un enlace de recuperación.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text('Enviar enlace',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen(authProvider, (_, current) {
      if (current.isAuthenticated) context.go(AppRoutes.dashboard);
      if (current.status == AuthStatus.error && current.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(current.error!)));
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
              _Header(),
              const SizedBox(height: 24),
              _MascotHero(),
              const SizedBox(height: 24),
              _WelcomeSection(),
              const SizedBox(height: 32),
              // Botón Google — única auth implementada
              _GoogleButton(
                isLoading: isLoading,
                onTap: () => ref.read(authProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: 16),
              _Divider(),
              const SizedBox(height: 16),
              _EmailField(controller: _emailCtrl),
              const SizedBox(height: 20),
              _PasswordField(
                controller:       _passwordCtrl,
                showPassword:     _showPassword,
                onToggle:         () => setState(() => _showPassword = !_showPassword),
                onForgotPassword: () => _showForgotDialog(context),
              ),
              const SizedBox(height: 12),
              _RememberCheckbox(
                value:     _rememberDevice,
                onChanged: (v) => setState(() => _rememberDevice = v ?? false),
              ),
              const SizedBox(height: 20),
              _SignInButton(
                isLoading: isLoading,
                onTap: () => ref.read(authProvider.notifier).signInWithEmail(
                  _emailCtrl.text,
                  _passwordCtrl.text,
                ),
              ),
              const SizedBox(height: 48),
              _RegisterRow(),
              const SizedBox(height: 16),
              _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Contenedor del logo con sombra
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 20),
                blurRadius: 25,
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 8),
                blurRadius: 10,
                spreadRadius: -6,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.verified_rounded, color: _kPrimary, size: 48),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verifarmac',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: _kTextDark,
                letterSpacing: -1.2,
              ),
            ),
            Opacity(
              opacity: 0.7,
              child: Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'HEALTH INTELLIGENCE WITH AI'
                    : 'INTELIGENCIA EN SALUD CON IA',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _kPrimary,
                  letterSpacing: 1.65,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Mascot Hero ─────────────────────────────────────────────────────────────

class _MascotHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final bubbleText = isEn
        ? '👋 Hi! I help you verify that your medicines are safe and authentic before taking them. Your health deserves the best! 💊'
        : '👋 ¡Hola! Te ayudo a asegurarte de que tus medicamentos sean seguros y auténticos antes de consumirlos. ¡Tu salud merece lo mejor! 💊';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Globo de diálogo
        _SpeechBubble(text: bubbleText),
        const SizedBox(height: 2),
        // Mascota
        Image.asset(
          'assets/images/mascot.png',
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox(height: 150),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EEF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD0D8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: _kTextDark,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Cola del globo apuntando hacia abajo (hacia la mascota)
        Positioned(
          bottom: -9,
          child: CustomPaint(
            size: const Size(18, 10),
            painter: _BubbleTailPainter(),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFE9EEF9)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFFD0D8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Welcome Section ──────────────────────────────────────────────────────────

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Welcome Back' : 'Bienvenido de nuevo',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: _kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEn
              ? 'Please enter your account details to continue.'
              : 'Ingresa los datos de tu cuenta para continuar.',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: _kTextSub,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onTap});
  final bool         isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
              )
            else ...[
              // Letras del logo Google con colores oficiales
              const _GoogleColorLogo(),
              const SizedBox(width: 12),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'Sign in with Google'
                    : 'Iniciar sesión con Google',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: _kTextSub,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoogleColorLogo extends StatelessWidget {
  const _GoogleColorLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0x4DC2C6D4), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isEn ? 'OR CONTINUE WITH EMAIL' : 'O CONTINÚA CON EMAIL',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: _kTextMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0x4DC2C6D4), thickness: 1),
        ),
      ],
    );
  }
}

// ─── Email Field ──────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'EMAIL ADDRESS' : 'CORREO ELECTRÓNICO',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: _kTextSub,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kInputBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16, color: _kTextDark),
            decoration: InputDecoration(
              hintText: Localizations.localeOf(context).languageCode == 'en'
                  ? 'name@clinical.com'
                  : 'correo@ejemplo.com',
              hintStyle: const TextStyle(color: _kPlaceholder, fontSize: 16),
              prefixIcon: const Icon(Icons.mail_outline_rounded, color: _kTextMuted, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Password Field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.showPassword,
    required this.onToggle,
    this.onForgotPassword,
  });
  final TextEditingController controller;
  final bool         showPassword;
  final VoidCallback onToggle;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? 'PASSWORD' : 'CONTRASEÑA',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _kTextSub,
                letterSpacing: 0.6,
              ),
            ),
            GestureDetector(
              onTap: onForgotPassword,
              child: Text(
                isEn ? 'FORGOT?' : '¿OLVIDASTE?',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _kPrimary,
                  letterSpacing: 0.55,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kInputBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller:    controller,
            obscureText:   !showPassword,
            style: const TextStyle(fontSize: 16, color: _kTextDark),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: _kPlaceholder, fontSize: 16),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: _kTextMuted, size: 18),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: _kTextMuted,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Remember Checkbox ────────────────────────────────────────────────────────

class _RememberCheckbox extends StatelessWidget {
  const _RememberCheckbox({required this.value, required this.onChanged});
  final bool                value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            side: const BorderSide(color: _kBorder),
            activeColor: _kPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isEn ? 'Remember this device for 30 days' : 'Recordar este dispositivo 30 días',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: _kTextSub,
          ),
        ),
      ],
    );
  }
}

// ─── Sign In Button (email/password — pendiente de implementar) ───────────────

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isLoading, required this.onTap});
  final bool         isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            BoxShadow(
              color: Color(0x3300478D),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -4,
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
            : Text(
                isEn ? 'Sign In to Dashboard' : 'Iniciar Sesión',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: 0.4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Badge('HIPAA COMPLIANT'),
              _Dot(),
              _Badge('GDPR SECURED'),
              _Dot(),
              _Badge('256-BIT AES'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        color: _kTextDark,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _kTextMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RegisterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.register),
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '¿No tienes cuenta? ',
                style: TextStyle(fontSize: 14, color: _kTextSub),
              ),
              TextSpan(
                text: 'Regístrate aquí',
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
    );
  }
}
