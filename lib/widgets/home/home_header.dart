import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';

/// Greeting on the left; language picker and CEFR badge on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.firstName,
    required this.cefrLevel,
  });

  final String greeting;
  final String firstName;
  final String cefrLevel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              // Wraps instead of truncating the name on narrow phones.
              Text(
                '$greeting, $firstName 👋',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 19,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const _LanguagePill(code: 'UZ'),
        const SizedBox(width: 8),
        _CefrBadge(level: cefrLevel),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Til: $code',
      child: Material(
        color: AppColors.primarySoft,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          // Language switching isn't implemented yet.
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.languages,
                  size: 17,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  code,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  LucideIcons.chevronDown,
                  size: 15,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'CEFR daraja: $level',
      excludeSemantics: true,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.successSoft,
          shape: BoxShape.circle,
        ),
        child: Text(
          level,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.successDark,
          ),
        ),
      ),
    );
  }
}
