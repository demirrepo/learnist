import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../constants/universities.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

enum _AuthMode { signIn, signUp }

const _otherUniversity = 'Boshqa / Other';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _universityController = TextEditingController();
  final _otherUniversityController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  String? _university;
  String? _universityError;
  bool _obscurePassword = true;
  bool _loading = false;

  late final StreamSubscription<AuthException> _linkErrorSubscription;

  bool get _isSignUp => _mode == _AuthMode.signUp;

  @override
  void initState() {
    super.initState();
    // Expired or reused reset links land here as auth stream errors.
    _linkErrorSubscription = ref
        .read(supabaseServiceProvider)
        .authLinkErrors
        .listen((error) {
          if (mounted) _showMessage(authErrorMessage(error), isError: true);
        });
  }

  Future<void> _openForgotPassword() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          _ForgotPasswordSheet(initialEmail: _emailController.text.trim()),
    );
    if (sent == true && mounted) _showMessage(passwordResetSentMessage);
  }

  @override
  void dispose() {
    _linkErrorSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _universityController.dispose();
    _otherUniversityController.dispose();
    super.dispose();
  }

  void _setMode(_AuthMode mode) {
    if (_loading || mode == _mode) return;
    setState(() {
      _mode = mode;
      _universityError = null;
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    if (_isSignUp) {
      setState(() {
        _universityError =
            _university == null ? 'Universitetingizni tanlang' : null;
      });
    }
    if (!formValid || (_isSignUp && _universityError != null)) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final service = ref.read(supabaseServiceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        final username = _usernameController.text.trim().toLowerCase();

        if (await service.isUsernameTaken(username)) {
          if (mounted) _showMessage(usernameTakenMessage, isError: true);
          return;
        }

        final response = await service.signUp(
          email: email,
          password: password,
          fullName: _fullNameController.text.trim(),
          username: username,
          university:
              _university == _otherUniversity
                  ? _otherUniversityController.text.trim()
                  : _university!,
        );
        // No session: the project requires email confirmation first.
        if (response.session == null && mounted) {
          _showMessage(
            "Tasdiqlash havolasi emailingizga yuborildi. "
            "Uni bosib, so'ng tizimga kiring.",
          );
          setState(() => _mode = _AuthMode.signIn);
        }
      } else {
        await service.signIn(email: email, password: password);
      }
      // On success the router redirect moves the user to /home.
    } catch (error, stackTrace) {
      // AuthException, PostgrestException and network errors are all
      // classified by authErrorMessage; only real connectivity failures get
      // the "no internet" message.
      logAuthError(_isSignUp ? 'Sign-up' : 'Sign-in', error, stackTrace);
      if (mounted) _showMessage(authErrorMessage(error), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: isError ? AppColors.danger : null,
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : LucideIcons.mail,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 32),
                  _Header(isSignUp: _isSignUp),
                  const SizedBox(height: 28),
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthModeToggle(
                mode: _mode,
                onChanged: _loading ? null : _setMode,
              ),
              const SizedBox(height: 24),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _isSignUp ? _buildSignUpFields() : const [],
                ),
              ),
              const _FieldLabel('Email'),
              TextFormField(
                key: const ValueKey('auth-email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(LucideIcons.mail, size: 20),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Password'),
              TextFormField(
                key: const ValueKey('auth-password'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: [
                  _isSignUp
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                onFieldSubmitted: (_) => _loading ? null : _submit(),
                decoration: InputDecoration(
                  hintText:
                      _isSignUp ? 'At least 6 characters' : 'Your password',
                  prefixIcon: const Icon(LucideIcons.lock, size: 20),
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 20,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty) return 'Parolni kiriting';
                  if (_isSignUp && password.length < 6) {
                    return "Parol kamida 6 ta belgidan iborat bo'lsin";
                  }
                  return null;
                },
              ),
              if (_isSignUp)
                const SizedBox(height: 28)
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: TextButton(
                      key: const ValueKey('auth-forgot-password'),
                      onPressed: _loading ? null : _openForgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        textStyle: GoogleFonts.manrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Parolni unutdingizmi?'),
                    ),
                  ),
                ),
              FilledButton(
                key: const ValueKey('auth-submit'),
                onPressed: _loading ? null : _submit,
                child:
                    _loading
                        ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_isSignUp ? 'Create account' : 'Sign In'),
                            const SizedBox(width: 8),
                            const Icon(LucideIcons.arrowRight, size: 20),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSignUpFields() {
    return [
      const _FieldLabel('Full Name'),
      TextFormField(
        key: const ValueKey('auth-full-name'),
        controller: _fullNameController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        decoration: const InputDecoration(
          hintText: 'Your full name',
          prefixIcon: Icon(LucideIcons.user, size: 20),
        ),
        validator:
            (value) =>
                (value?.trim().length ?? 0) < 3
                    ? "To'liq ismingizni kiriting"
                    : null,
      ),
      const SizedBox(height: 18),
      const _FieldLabel('Username'),
      TextFormField(
        key: const ValueKey('auth-username'),
        controller: _usernameController,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.newUsername],
        decoration: const InputDecoration(
          hintText: 'e.g. learner_01',
          prefixIcon: Icon(LucideIcons.atSign, size: 20),
        ),
        validator: (value) {
          final username = value?.trim() ?? '';
          if (!RegExp(r'^[a-zA-Z0-9_.]{3,30}$').hasMatch(username)) {
            return "3–30 ta belgi: harflar, raqamlar, _ yoki .";
          }
          return null;
        },
      ),
      const SizedBox(height: 18),
      const _FieldLabel('University'),
      DropdownMenu<String>(
        key: const ValueKey('auth-university'),
        controller: _universityController,
        expandedInsets: EdgeInsets.zero,
        enableFilter: true,
        requestFocusOnTap: true,
        menuHeight: 320,
        hintText: 'Search your university',
        textStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        leadingIcon: const Icon(LucideIcons.graduationCap, size: 20),
        trailingIcon: const Icon(LucideIcons.chevronDown, size: 20),
        selectedTrailingIcon: const Icon(LucideIcons.search, size: 20),
        errorText: _universityError,
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(6),
          shadowColor: WidgetStatePropertyAll(
            AppColors.textPrimary.withValues(alpha: 0.25),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        dropdownMenuEntries: [
          for (final university in uzbekUniversities)
            DropdownMenuEntry(
              value: university,
              label: university,
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
        onSelected:
            (value) => setState(() {
              _university = value;
              if (value != null) _universityError = null;
            }),
      ),
      if (_university == _otherUniversity) ...[
        const SizedBox(height: 18),
        const _FieldLabel('University name'),
        TextFormField(
          key: const ValueKey('auth-other-university'),
          controller: _otherUniversityController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Type your university name',
            prefixIcon: Icon(LucideIcons.pencil, size: 20),
          ),
          validator:
              (value) =>
                  (value?.trim().isEmpty ?? true)
                      ? 'Universitet nomini kiriting'
                      : null,
        ),
      ],
      const SizedBox(height: 18),
    ];
  }

  Widget _buildFooter() {
    final style = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : 'New to Learnist?',
          style: style,
        ),
        TextButton(
          onPressed:
              _loading
                  ? null
                  : () =>
                      _setMode(_isSignUp ? _AuthMode.signIn : _AuthMode.signUp),
          child: Text(_isSignUp ? 'Sign in instead' : 'Create an account'),
        ),
      ],
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Emailingizni kiriting';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return "Email manzili noto'g'ri";
  }
  return null;
}

/// Bottom sheet that requests a password reset email. Pops `true` on success;
/// errors stay inline because a SnackBar would sit behind the sheet.
class _ForgotPasswordSheet extends ConsumerStatefulWidget {
  const _ForgotPasswordSheet({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await ref
          .read(supabaseServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      logAuthError('Password reset email', error, stackTrace);
      if (mounted) {
        setState(() {
          _error = authErrorMessage(error);
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.lock,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Parolni tiklash',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Hisobingizga bog'langan emailni kiriting — parolni tiklash "
              "havolasini yuboramiz.",
              style: GoogleFonts.manrope(
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Email'),
            TextFormField(
              key: const ValueKey('forgot-email'),
              controller: _emailController,
              autofocus: widget.initialEmail.isEmpty,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _sending ? null : _send(),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(LucideIcons.mail, size: 20),
              ),
              validator: _validateEmail,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('forgot-submit'),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Havolani yuborish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Learnist',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSignUp ? 'START YOUR ENGLISH JOURNEY' : 'WELCOME BACK',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isSignUp ? 'Create your account' : 'Sign in to Learnist',
          style: GoogleFonts.manrope(
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp
              ? 'Join thousands of students preparing for their CEFR certificate.'
              : 'Pick up right where you left off.',
          style: GoogleFonts.manrope(
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped two-way switch, styled like the mockups' tab chips.
class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({required this.mode, required this.onChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: const ShapeDecoration(
        color: AppColors.track,
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          for (final (value, label) in const [
            (_AuthMode.signIn, 'Sign In'),
            (_AuthMode.signUp, 'Sign Up'),
          ])
            Expanded(
              child: _ToggleSegment(
                label: label,
                selected: value == mode,
                onTap: onChanged == null ? null : () => onChanged!(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            shape: const StadiumBorder(),
            shadows:
                selected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : const [],
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
