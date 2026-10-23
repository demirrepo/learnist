import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Opened by the router after a password reset link; the user stays here
/// until they save a new password or cancel.
class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    // Captured up front: on success the router replaces this screen before
    // the SnackBar is shown.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _saving = true);

    try {
      await ref
          .read(supabaseServiceProvider)
          .updatePassword(_passwordController.text);
      _showSnackBar(messenger, l10n.passwordUpdated);
    } catch (error, stackTrace) {
      logAuthError('Password update', error, stackTrace);
      _showSnackBar(messenger, authErrorMessage(error, l10n), isError: true);
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancel() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _saving = true);

    try {
      await ref.read(supabaseServiceProvider).cancelPasswordRecovery();
    } catch (error, stackTrace) {
      logAuthError('Cancel password recovery', error, stackTrace);
      _showSnackBar(messenger, authErrorMessage(error, l10n), isError: true);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.passwordEyebrow,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.passwordTitle,
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
                    l10n.passwordBody,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildFormCard(),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      key: const ValueKey('update-password-cancel'),
                      onPressed: _saving ? null : _cancel,
                      child: Text(l10n.cancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final l10n = context.l10n;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                l10n.passwordNew,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextFormField(
              key: const ValueKey('update-password-field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _saving ? null : _save(),
              decoration: InputDecoration(
                hintText: l10n.authPasswordHintNew,
                prefixIcon: const Icon(LucideIcons.lock, size: 20),
                suffixIcon: IconButton(
                  tooltip:
                      _obscurePassword
                          ? l10n.authShowPassword
                          : l10n.authHidePassword,
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 20,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) return l10n.passwordNewRequired;
                if (password.length < 6) return l10n.authPasswordTooShort;
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('update-password-submit'),
              onPressed: _saving ? null : _save,
              child:
                  _saving
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
                          Text(l10n.passwordSave),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrowRight, size: 20),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSnackBar(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.danger : null,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
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
