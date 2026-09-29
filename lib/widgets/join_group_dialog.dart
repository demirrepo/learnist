import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/teacher_dashboard.dart';
import '../services/teacher_service.dart';
import '../theme/app_theme.dart';

/// Opens [JoinGroupDialog] and shows the outcome in a snackbar.
Future<void> showJoinGroupDialog(BuildContext context) async {
  final result = await showDialog<JoinGroupResult>(
    context: context,
    builder: (_) => const JoinGroupDialog(),
  );
  if (result == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(joinGroupSuccessMessage(result))));
}

/// "Guruhga qo'shilish": the class login and password a teacher shared.
///
/// Closes with the [JoinGroupResult] on success. Errors are shown inside
/// the dialog, where a snackbar would sit under the modal barrier, and the
/// fields are kept for another try.
class JoinGroupDialog extends ConsumerStatefulWidget {
  const JoinGroupDialog({super.key});

  @override
  ConsumerState<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends ConsumerState<JoinGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(teacherServiceProvider)
          .joinGroup(login: _login.text, password: _password.text);
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (mounted) setState(() => _error = joinGroupErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? "Maydonni to'ldiring." : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        "Guruhga qo'shilish",
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "O'qituvchingiz bergan login va parolni kiriting.",
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('join-group-login'),
                controller: _login,
                enabled: !_busy,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Class login'),
                validator: _required,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('join-group-password'),
                controller: _password,
                enabled: !_busy,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(labelText: 'Password'),
                validator: _required,
              ),
              if (_error case final error?) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          key: const ValueKey('join-group-submit'),
          onPressed: _busy ? null : _submit,
          child:
              _busy
                  ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                  : const Text("Qo'shilish"),
        ),
      ],
    );
  }
}
