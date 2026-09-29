import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Greeting on the left; CEFR badge on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.firstName,
    required this.cefrLevel,
  });

  final String greeting;
  final String firstName;

  /// Null until the first level check-up.
  final String? cefrLevel;

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
        _CefrBadge(level: cefrLevel),
      ],
    );
  }
}

class _CefrBadge extends StatelessWidget {
  const _CefrBadge({required this.level});

  final String? level;

  @override
  Widget build(BuildContext context) {
    final colors = cefrColors(level);

    return Semantics(
      label:
          level == null
              ? "CEFR daraja: hali aniqlanmagan"
              : 'CEFR daraja: $level',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('home-cefr-badge'),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: Text(
          level ?? 'N/A',
          style: GoogleFonts.manrope(
            fontSize: level == null ? 12 : 14,
            fontWeight: FontWeight.w800,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}
