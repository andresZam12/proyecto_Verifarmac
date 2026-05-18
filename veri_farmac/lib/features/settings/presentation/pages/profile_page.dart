import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

const _kPrimary = Color(0xFF00478D);
const _kGreen   = Color(0xFF006D41);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _birthCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  bool _saving  = false;
  bool _editing = false;
  String _savedName = '', _savedBirth = '', _savedPhone = '', _savedCity = '';
  Map<String, String?> _errors = {};

  void _startEditing() {
    _savedName  = _nameCtrl.text;
    _savedBirth = _birthCtrl.text;
    _savedPhone = _phoneCtrl.text;
    _savedCity  = _cityCtrl.text;
    setState(() { _editing = true; _errors.clear(); });
  }

  void _cancelEditing() {
    _nameCtrl.text  = _savedName;
    _birthCtrl.text = _savedBirth;
    _phoneCtrl.text = _savedPhone;
    _cityCtrl.text  = _savedCity;
    setState(() { _editing = false; _errors.clear(); });
  }

  // Detecta cadenas sin sentido: al menos 20 % de las letras deben ser vocales
  bool _tieneSuficientesVocales(String texto) {
    final letras = texto.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚüÜñÑ]'), '');
    if (letras.isEmpty) return true;
    final vocales = letras.replaceAll(
        RegExp(r'[^aeiouáéíóúAEIOUÁÉÍÓÚüÜ]'), '');
    return vocales.length / letras.length >= 0.20;
  }

  bool _validate() {
    final e = <String, String?>{};

    // Nombre: letras, tildes, espacios, guión; densidad de vocales mínima
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      if (name.length < 2) {
        e['name'] = 'Mínimo 2 caracteres';
      } else if (name.length > 60) {
        e['name'] = 'Máximo 60 caracteres';
      } else if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s\-']+$").hasMatch(name)) {
        e['name'] = 'Solo letras, espacios y guiones';
      } else if (!_tieneSuficientesVocales(name)) {
        e['name'] = 'Ingresa un nombre real (ej: Juan García)';
      }
    }

    // Fecha de nacimiento: DD/MM/AAAA, real, no futura, no más de 120 años
    final birth = _birthCtrl.text.trim();
    if (birth.isNotEmpty) {
      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(birth)) {
        e['birth'] = 'Formato requerido: DD/MM/AAAA';
      } else {
        try {
          final p    = birth.split('/');
          final date = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
          final now  = DateTime.now();
          if (date.isAfter(now)) {
            e['birth'] = 'No puede ser una fecha futura';
          } else if (now.difference(date).inDays > 120 * 365) {
            e['birth'] = 'Fecha de nacimiento no válida';
          }
        } catch (_) {
          e['birth'] = 'Fecha no válida (ej: 25/12/1990)';
        }
      }
    }

    // Teléfono: mínimo 10 dígitos (estándar Colombia), máximo 15
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty) {
      if (phone.contains(RegExp(r'[a-zA-Z]'))) {
        e['phone'] = 'Solo números, +, espacios y guiones';
      } else {
        final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.length < 10) {
          e['phone'] = 'Ingresa al menos 10 dígitos (ej: 3001234567)';
        } else if (digits.length > 15) {
          e['phone'] = 'Máximo 15 dígitos';
        }
      }
    }

    // Ciudad/Región: letras, tildes, espacios; densidad de vocales mínima
    final city = _cityCtrl.text.trim();
    if (city.isNotEmpty) {
      if (city.length < 2) {
        e['city'] = 'Mínimo 2 caracteres';
      } else if (city.length > 60) {
        e['city'] = 'Máximo 60 caracteres';
      } else if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s\-\/\.]+$").hasMatch(city)) {
        e['city'] = 'Solo letras, espacios y caracteres válidos';
      } else if (!_tieneSuficientesVocales(city)) {
        e['city'] = 'Ingresa una ciudad o región real (ej: Pasto)';
      }
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(e);
    });
    return e.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    final prefs      = ref.read(sharedPrefsProvider);
    final user       = Supabase.instance.client.auth.currentUser;
    final authState  = ref.read(authProvider);
    // Nombre: full_name > name (Google OAuth) > prefijo de email (Supabase o local)
    final supaName   = ((user?.userMetadata?['full_name'] as String?
                       ?? user?.userMetadata?['name'] as String?) ?? '').trim();
    final email      = user?.email ?? authState.localEmail ?? '';
    final emailName  = email.isNotEmpty ? email.split('@').first : '';
    final fallback   = supaName.isNotEmpty ? supaName : emailName;

    _nameCtrl  = TextEditingController(text: prefs.getString('profile_name')  ?? fallback);
    _birthCtrl = TextEditingController(text: prefs.getString('profile_birth') ?? '');
    _phoneCtrl = TextEditingController(text: prefs.getString('profile_phone') ?? '');
    _cityCtrl  = TextEditingController(text: prefs.getString('profile_city')  ?? '');

    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_editing) return;
    if (!_validate()) return;
    setState(() => _saving = true);
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('profile_name',  _nameCtrl.text.trim());
    await prefs.setString('profile_birth', _birthCtrl.text.trim());
    await prefs.setString('profile_phone', _phoneCtrl.text.trim());
    await prefs.setString('profile_city',  _cityCtrl.text.trim());
    if (mounted) {
      setState(() { _saving = false; _editing = false; _errors.clear(); });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil guardado correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n      = context.l10n;
    final user      = Supabase.instance.client.auth.currentUser;
    final authState = ref.watch(authProvider);
    // Email: prioridad → Supabase > login local hardcodeado
    final email  = user?.email ?? authState.localEmail ?? '';
    final avatar = user?.userMetadata?['avatar_url'] as String?;
    final dash   = ref.watch(dashboardProvider);

    // Nombre: campo editado > full_name > name (Google) > prefijo del email
    final emailName = email.isNotEmpty ? email.split('@').first : '';
    final metaName  = (user?.userMetadata?['full_name'] as String?
                    ?? user?.userMetadata?['name'] as String? ?? '').trim();
    final displayName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : metaName.isNotEmpty
            ? metaName
            : emailName.isNotEmpty ? emailName : email;
    final rawId   = user?.id ?? 'LOCAL';
    final shortId = rawId == 'LOCAL'
        ? 'VF-LOCAL'
        : 'VF-${rawId.replaceAll('-', '').substring(0, 5).toUpperCase()}';

    final total    = dash.total;
    final accuracy = total > 0 ? (dash.valid / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const _BottomNavBar(),
      body: Column(children: [

        _TopBar(onSettings: () => context.push(AppRoutes.settings)),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(children: [

              _ProfileHeader(
                name:    displayName,
                avatar:  avatar,
                shortId: shortId,
                l10n:    l10n,
              ),
              const SizedBox(height: 20),

              _ActivityCard(total: total, accuracy: accuracy, l10n: l10n),
              const SizedBox(height: 20),

              _PersonalInfoSection(
                email:     email,
                nameCtrl:  _nameCtrl,
                birthCtrl: _birthCtrl,
                phoneCtrl: _phoneCtrl,
                cityCtrl:  _cityCtrl,
                l10n:      l10n,
                errors:    _errors,
                editing:   _editing,
                onEdit:    _startEditing,
              ),
              const SizedBox(height: 28),

              _ActionButtons(
                l10n:      l10n,
                saving:    _saving,
                editing:   _editing,
                onEdit:    _startEditing,
                onDiscard: _editing
                    ? _cancelEditing
                    : () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.dashboard),
                onSave:    _save,
                onSignOut: () => _confirmSignOut(context, ref, l10n),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref, dynamic l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.signOut,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(l10n.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(color: context.textSub)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: Text(l10n.signOut,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── TopBar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_rounded,
                color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Verifarmac',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textDark,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSettings,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: context.pillBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: _kPrimary, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.avatar,
    required this.shortId,
    required this.l10n,
  });
  final String  name;
  final String? avatar;
  final String  shortId;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'U';

    return Column(children: [
      Stack(children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kPrimary.withValues(alpha: 0.3), width: 3),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: avatar != null
                ? Image.network(avatar!, fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => _AvatarFallback(initials, context))
                : _AvatarFallback(initials, context),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: _kPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: context.cardColor, width: 2),
            ),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 13),
          ),
        ),
      ]),
      const SizedBox(height: 14),

      Text(
        name,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: context.textDark,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),

      Text(
        l10n.memberLabel,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.isDarkMode ? const Color(0xFF77DA9F) : _kGreen,
        ),
      ),
      const SizedBox(height: 10),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Badge(label: 'ID: $shortId', color: context.pillBg, textColor: _kPrimary),
          const SizedBox(width: 8),
          _Badge(
            label:     l10n.activeMember,
            color:     context.isDarkMode ? const Color(0xFF0D2218) : const Color(0xFFE6F4ED),
            textColor: context.isDarkMode ? const Color(0xFF77DA9F) : _kGreen,
          ),
        ],
      ),
    ]);
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback(this.initials, this.ctx);
  final String       initials;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ctx.pillBg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: _kPrimary,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.textColor});
  final String label;
  final Color  color;
  final Color  textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Activity Card ────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.total, required this.accuracy, required this.l10n});
  final int     total;
  final int     accuracy;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.pillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          l10n.activityTitle,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.totalScansActivity,
                style: TextStyle(
                    fontSize: 13, color: context.textSub, fontWeight: FontWeight.w500)),
            Text('$total',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: context.textDark)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: accuracy / 100,
            minHeight: 6,
            backgroundColor: context.cardColor,
            valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text('$accuracy% ${l10n.verificationAccuracy}',
            style: TextStyle(fontSize: 11, color: context.textSub)),
      ]),
    );
  }
}

// ─── Personal Info Section ────────────────────────────────────────────────────

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({
    required this.email,
    required this.nameCtrl,
    required this.birthCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    required this.l10n,
    required this.onEdit,
    this.errors  = const {},
    this.editing = false,
  });
  final String                email;
  final TextEditingController nameCtrl;
  final TextEditingController birthCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final dynamic               l10n;
  final VoidCallback          onEdit;
  final Map<String, String?>  errors;
  final bool                  editing;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(Icons.manage_accounts_rounded, color: _kPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.personalInformation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textDark,
              ),
            ),
          ]),
          if (!editing)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_rounded, size: 12, color: _kPrimary),
                  const SizedBox(width: 5),
                  Text(
                    l10n.editAll,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kPrimary,
                    ),
                  ),
                ]),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                const Text(
                  'EDITANDO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                    letterSpacing: 0.4,
                  ),
                ),
              ]),
            ),
        ],
      ),
      const SizedBox(height: 16),

      _EditableField(
        label:      'NOMBRE COMPLETO',
        controller: nameCtrl,
        icon:       Icons.person_outline_rounded,
        readOnly:   !editing,
        errorText:  errors['name'],
      ),
      const SizedBox(height: 10),

      _ReadOnlyField(
        label: l10n.emailLabel,
        value: email.isNotEmpty ? email : '—',
        icon:  Icons.mail_outline_rounded,
      ),
      const SizedBox(height: 10),

      _EditableField(
        label:        l10n.dateOfBirthLabel,
        controller:   birthCtrl,
        icon:         Icons.cake_outlined,
        keyboardType: TextInputType.datetime,
        hint:         'DD/MM/AAAA',
        readOnly:     !editing,
        errorText:    errors['birth'],
      ),
      const SizedBox(height: 10),

      _EditableField(
        label:        l10n.professionalPhoneLabel,
        controller:   phoneCtrl,
        icon:         Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        hint:         '+57 300 000 0000',
        readOnly:     !editing,
        errorText:    errors['phone'],
      ),
      const SizedBox(height: 10),

      _EditableField(
        label:      l10n.cityRegionLabel,
        controller: cityCtrl,
        icon:       Icons.location_city_outlined,
        hint:       'Pasto / Nariño',
        readOnly:   !editing,
        errorText:  errors['city'],
      ),
    ]);
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.hint,
    this.errorText,
    this.readOnly = false,
  });
  final String                 label;
  final TextEditingController  controller;
  final IconData               icon;
  final TextInputType?         keyboardType;
  final String?                hint;
  final String?                errorText;
  final bool                   readOnly;

  @override
  Widget build(BuildContext context) {
    final hasError  = errorText != null && !readOnly;
    final iconColor = readOnly
        ? context.textSub.withValues(alpha: 0.35)
        : hasError
            ? Colors.red.shade400
            : _kPrimary.withValues(alpha: 0.6);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: hasError ? Colors.red.shade700 : context.textSub,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          color: readOnly
              ? context.inputBg.withValues(alpha: 0.5)
              : context.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: hasError
              ? Border.all(color: Colors.red.shade400, width: 1.5)
              : null,
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller:   controller,
              keyboardType: keyboardType,
              readOnly:     readOnly,
              style: TextStyle(
                fontSize: 14,
                color: readOnly ? context.textSub : context.textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText:       hint,
                hintStyle:      TextStyle(color: context.textSub.withValues(alpha: 0.5)),
                prefixIcon:     Icon(icon, size: 16, color: iconColor),
                border:         InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
            ),
          ),
          if (readOnly)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.lock_outline_rounded,
                  size: 13, color: context.textSub.withValues(alpha: 0.35)),
            ),
        ]),
      ),
      if (hasError) ...[
        const SizedBox(height: 4),
        Text(
          errorText!,
          style: TextStyle(
            fontSize: 11,
            color: Colors.red.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ]);
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value, required this.icon});
  final String   label;
  final String   value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: context.textSub,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: context.inputBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: context.textSub.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: context.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 12, color: context.textSub.withValues(alpha: 0.4)),
        ]),
      ),
    ]);
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.l10n,
    required this.saving,
    required this.editing,
    required this.onEdit,
    required this.onDiscard,
    required this.onSave,
    required this.onSignOut,
  });
  final dynamic      l10n;
  final bool         saving;
  final bool         editing;
  final VoidCallback onEdit;
  final VoidCallback onDiscard;
  final VoidCallback onSave;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (!editing)
        // ── Modo lectura: botón "Editar perfil" ──────────────────
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              backgroundColor: _kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon:  const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Editar perfil',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        )
      else
        // ── Modo edición: Descartar + Guardar ────────────────────
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: saving ? null : onDiscard,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _kPrimary.withValues(alpha: 0.4)),
                foregroundColor: _kPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.discard,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: saving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: _kPrimary,
                disabledBackgroundColor: _kPrimary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.saveChanges,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onSignOut,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.2),
            foregroundColor: const Color(0xFFBA1A1A),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: Text(l10n.signOut,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon:  Icons.home_rounded,
                label: l10n.home.toUpperCase(),
                onTap: () => context.go(AppRoutes.dashboard),
              ),
              _NavItem(
                icon:  Icons.map_rounded,
                label: l10n.map.toUpperCase(),
                onTap: () => context.go(AppRoutes.map),
              ),
              _NavItem(
                icon:  Icons.qr_code_scanner_rounded,
                label: l10n.scan.toUpperCase(),
                onTap: () => context.go(AppRoutes.scanner),
              ),
              _NavItem(
                icon:     Icons.person_rounded,
                label:    l10n.profile.toUpperCase(),
                isActive: true,
                onTap:    () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         isActive;

  @override
  Widget build(BuildContext context) {
    const activeColor  = _kPrimary;
    final activePillBg = context.pillBg;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activePillBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: isActive ? activeColor : context.textSub, size: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : context.textSub,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
