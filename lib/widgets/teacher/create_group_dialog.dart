import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/teacher_service.dart';
import '../../theme/app_theme.dart';

/// Opens [CreateGroupDialog]; completes with the new group's name, or null
/// if the teacher cancelled.
Future<String?> showCreateGroupDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const CreateGroupDialog(),
  );
}

/// Name, class login and password for a new group. Failures stay in the
/// dialog so the teacher can fix the login without retyping everything.
class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
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
      await ref
          .read(teacherServiceProvider)
          .createGroup(
            name: _name.text,
            login: _login.text,
            password: _password.text,
          );
      if (mounted) Navigator.of(context).pop(_name.text.trim());
    } catch (error) {
      if (mounted) setState(() => _error = createGroupErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Create group',
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
              TextFormField(
                key: const ValueKey('create-group-name'),
                controller: _name,
                enabled: !_busy,
                maxLength: 80,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Group name'),
                validator:
                    (value) =>
                        (value ?? '').trim().isEmpty
                            ? "Guruh nomini kiriting."
                            : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('create-group-login'),
                controller: _login,
                enabled: !_busy,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Class login',
                  helperText: '3–32 characters: A–Z, 0–9, _ or -',
                ),
                validator:
                    (value) =>
                        TeacherService.loginPattern.hasMatch(
                              TeacherService.normalizeLogin(value ?? ''),
                            )
                            ? null
                            : "Login 3–32 ta harf, raqam, _ yoki - bo'lsin.",
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('create-group-password'),
                controller: _password,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  final length = (value ?? '').trim().length;
                  return length < 4 || length > 64
                      ? "Parol 4–64 ta belgidan iborat bo'lsin."
                      : null;
                },
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('create-group-submit'),
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teacherAccent,
          ),
          child:
              _busy
                  ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Create'),
        ),
      ],
    );
  }
}
