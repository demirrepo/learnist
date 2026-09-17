import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../router.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

const _pagePadding = 20.0;
const _cardRadius = BorderRadius.all(Radius.circular(16));

const _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: _cardRadius,
  border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
  boxShadow: [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 6)),
  ],
);

// Placeholder stats until progress comes from the backend.
const _stats = [
  _Stat(icon: LucideIcons.trophy, value: '1/52', label: "O'rganilgan mavzular"),
  _Stat(icon: LucideIcons.target, value: '85%', label: "O'rtacha natija"),
];

const _settings = [
  (
    icon: LucideIcons.userCog,
    label: 'Tahrirlash',
    route: AppRoutes.editProfile,
  ),
  (
    icon: Icons.troubleshoot,
    label: 'Xatolar xaritasi',
    route: AppRoutes.errorMap,
  ),
];

// UI only for now; strings are not translated until l10n lands.
const _languages = ["O'zbekcha", 'English', 'Русский'];

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(supabaseServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(_pagePadding, 8, _pagePadding, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rebuild when auth notifies, e.g. after metadata is updated.
            ListenableBuilder(
              listenable: auth,
              builder:
                  (context, _) => ProfileHeader(
                    fullName: auth.currentUserFullName,
                    username: auth.currentUsername,
                    university: auth.currentUserUniversity,
                  ),
            ),
            const SizedBox(height: 16),
            const _StatsRow(stats: _stats),
            const SizedBox(height: 24),
            const _SettingsCard(),
            const SizedBox(height: 16),
            _SignOutButton(onSignOut: auth.signOut),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name, @username and university badge. Missing metadata falls
/// back to "Foydalanuvchi" / "Talaba"; a missing username is hidden.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.username,
    required this.university,
  });

  final String? fullName;
  final String? username;
  final String? university;

  @override
  Widget build(BuildContext context) {
    final initials = initialsFrom(fullName);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: _cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            child:
                initials == null
                    ? const Icon(LucideIcons.user, size: 36)
                    : Text(
                      initials,
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName ?? 'Foydalanuvchi',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          if (username != null) ...[
            const SizedBox(height: 4),
            Text(
              '@$username',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _UniversityBadge(label: university ?? 'Talaba'),
        ],
      ),
    );
  }
}

class _UniversityBadge extends StatelessWidget {
  const _UniversityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Universitet: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            // Long university names wrap instead of overflowing.
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight keeps both cards equally tall when a label wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _StatCard(stat: stats[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stat.label}: ${stat.value}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(stat.icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              stat.value,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatefulWidget {
  const _SettingsCard();

  @override
  State<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<_SettingsCard> {
  String _language = _languages.first;

  void _openLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (sheetContext) => _LanguageSheet(
            selected: _language,
            onSelected: (language) {
              setState(() => _language = language);
              sheetContext.pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, indent: 64, color: AppColors.border);

    return Container(
      decoration: _cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (final setting in _settings) ...[
              _SettingsTile(
                icon: setting.icon,
                label: setting.label,
                onTap: () => context.push(setting.route),
              ),
              divider,
            ],
            _SettingsTile(
              icon: Icons.language,
              label: 'Til',
              value: _language,
              onTap: _openLanguageSheet,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Current value shown in gray before the chevron.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.hint,
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.hint),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Tilni tanlang',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final language in _languages)
              _LanguageOption(
                label: language,
                selected: language == selected,
                onTap: () => onSelected(language),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
      selectedTileColor: AppColors.primarySoft,
      title: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing:
          selected
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : null,
      onTap: onTap,
    );
  }
}

/// Signing out notifies the auth service, and the router's redirect then
/// sends the user to /auth.
class _SignOutButton extends StatefulWidget {
  const _SignOutButton({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _busy = false;

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await widget.onSignOut();
    } catch (error, stackTrace) {
      logAuthError('Sign out', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _busy ? null : _signOut,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.danger,
        disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.5),
      ),
      icon:
          _busy
              ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
              : const Icon(LucideIcons.logOut, size: 20),
      label: const Text('Tizimdan chiqish'),
    );
  }
}

/// Up to two uppercase initials, or null when there is no usable name.
@visibleForTesting
String? initialsFrom(String? fullName) {
  final words =
      (fullName ?? '')
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
  if (words.isEmpty) return null;
  return words
      .take(2)
      .map((word) => word.characters.first)
      .join()
      .toUpperCase();
}
