import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../constants/universities.dart';
import '../router.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

const profileSavedMessage = "O'zgarishlar muvaffaqiyatli saqlandi";

final _usernamePattern = RegExp(r'^[a-z0-9_.]{3,30}$');

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _universityController;
  final _universityFocus = FocusNode();

  late final String _initialFullName;
  late final String _initialUsername;
  late final String _initialUniversity;

  bool _saving = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(supabaseServiceProvider);
    _initialFullName = auth.currentUserFullName ?? '';
    _initialUsername = auth.currentUsername ?? '';
    _initialUniversity = auth.currentUserUniversity ?? '';
    _fullNameController = TextEditingController(text: _initialFullName);
    _usernameController = TextEditingController(text: _initialUsername);
    _universityController = TextEditingController(text: _initialUniversity);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _universityController.dispose();
    _universityFocus.dispose();
    super.dispose();
  }

  String get _fullName => _fullNameController.text.trim();
  String get _username => _usernameController.text.trim().toLowerCase();
  String get _university => _universityController.text.trim();

  bool get _hasChanges =>
      _fullName != _initialFullName ||
      _username != _initialUsername.toLowerCase() ||
      _university != _initialUniversity;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _usernameError = null);
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(supabaseServiceProvider);
    final fullName = _fullName;
    final username = _username;
    final university = _university;

    setState(() => _saving = true);
    try {
      if (username != _initialUsername.toLowerCase() &&
          await auth.isUsernameTaken(username)) {
        if (mounted) {
          setState(() => _usernameError = profileUsernameTakenMessage);
        }
        return;
      }

      await auth.updateProfile(
        fullName: fullName,
        username: username,
        university: university,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(profileSavedMessage)));
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.profile);
      }
    } catch (error, stackTrace) {
      logAuthError('Profile update', error, stackTrace);
      if (!mounted) return;
      final message = profileUpdateErrorMessage(error);
      if (message == profileUsernameTakenMessage) {
        setState(() => _usernameError = message);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Blocks the back button and system back while a save is in flight.
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Profilni tahrirlash',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: _saving,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('Ism va familiya'),
                    TextFormField(
                      key: const ValueKey('edit-full-name'),
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Demir',
                        prefixIcon: Icon(LucideIcons.user, size: 20),
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 3
                          ? "To'liq ismingizni kiriting"
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Foydalanuvchi nomi'),
                    TextFormField(
                      key: const ValueKey('edit-username'),
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.username],
                      onChanged: (_) => setState(() => _usernameError = null),
                      decoration: InputDecoration(
                        hintText: 'demir_dev',
                        prefixIcon: const Icon(LucideIcons.atSign, size: 20),
                        errorText: _usernameError,
                        errorMaxLines: 2,
                      ),
                      validator: (value) => _usernamePattern
                              .hasMatch(value?.trim().toLowerCase() ?? '')
                          ? null
                          : "3–30 ta belgi: harflar, raqamlar, _ yoki .",
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Universitet'),
                    _UniversityField(
                      controller: _universityController,
                      focusNode: _universityFocus,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      key: const ValueKey('edit-save'),
                      onPressed: _saving || !_hasChanges ? null : _save,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Saqlash'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Free-text field that suggests names from [uzbekUniversities], so
/// universities missing from the list can still be typed in.
class _UniversityField extends StatelessWidget {
  const _UniversityField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable.empty();
        return uzbekUniversities
            .where((name) => name.toLowerCase().contains(query))
            .take(8);
      },
      onSelected: (_) => onChanged(),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          key: const ValueKey('edit-university'),
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onChanged(),
          onFieldSubmitted: (_) => onSubmitted(),
          decoration: const InputDecoration(
            hintText: 'Millat Umidi University',
            prefixIcon: Icon(LucideIcons.graduationCap, size: 20),
          ),
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Universitet nomini kiriting'
              : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final width = MediaQuery.sizeOf(context).width - 40;
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Material(
              color: AppColors.surface,
              elevation: 6,
              shadowColor: AppColors.textPrimary.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 260, maxWidth: width),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  children: [
                    for (final option in options)
                      ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onTap: () => onSelected(option),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
