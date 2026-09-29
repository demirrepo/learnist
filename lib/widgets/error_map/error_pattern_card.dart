import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/tracked_mistake.dart';
import '../../theme/app_theme.dart';

enum ErrorSeverity {
  high(AppColors.danger, 'yuqori'),
  medium(AppColors.warning, "o'rta");

  const ErrorSeverity(this.color, this.label);

  final Color color;
  final String label;
}

/// One weakness: every mistake of the same kind across recent tests,
/// grouped under a single rule.
class ErrorPattern {
  const ErrorPattern({
    required this.rule,
    this.example,
    this.correction,
    required this.mistakeCount,
    required this.lessonLabel,
    required this.lessonNumber,
  });

  /// The grammar point the mistakes have in common.
  final String rule;

  /// A typical wrong sentence and its fix, to show what the pattern is;
  /// null when the mistake isn't described yet.
  final String? example;
  final String? correction;

  /// Mistakes of this kind in recent tests.
  final int mistakeCount;

  /// The lesson that teaches [rule].
  final String lessonLabel;
  final int lessonNumber;

  bool get isRecurring => mistakeCount >= TrackedMistake.recurringThreshold;

  /// Red from [TrackedMistake.highThreshold], yellow below it.
  ErrorSeverity get severity =>
      mistakeCount >= TrackedMistake.highThreshold
          ? ErrorSeverity.high
          : ErrorSeverity.medium;
}

/// Tappable card for one recurring pattern; [onReview] opens its lesson.
class ErrorPatternCard extends StatelessWidget {
  const ErrorPatternCard({
    super.key,
    required this.pattern,
    required this.onReview,
  });

  final ErrorPattern pattern;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final severity = pattern.severity;

    return Semantics(
      button: true,
      label:
          '${pattern.rule}. '
          "So'nggi testlarda ${pattern.mistakeCount} marta xato qilingan. "
          'Ustuvorlik: ${severity.label}. '
          'Darsni takrorlash: ${pattern.lessonLabel}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onReview,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            decoration: const BoxDecoration(
              borderRadius: radius,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.border),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pattern.rule,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: severity.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "So'nggi testlarda ${pattern.mistakeCount} marta "
                  'xato qilingan',
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                if ((pattern.example, pattern.correction) case (
                  final wrong?,
                  final right?,
                )) ...[
                  const SizedBox(height: 12),
                  _ExampleBox(wrong: wrong, right: right),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Darsni takrorlash',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            pattern.lessonLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "✗ wrong / ✓ right" pair illustrating the pattern.
class _ExampleBox extends StatelessWidget {
  const _ExampleBox({required this.wrong, required this.right});

  final String wrong;
  final String right;

  @override
  Widget build(BuildContext context) {
    Widget line(
      IconData icon,
      Color color,
      String text, {
      bool struck = false,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                decoration: struck ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.danger,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          line(LucideIcons.x, AppColors.danger, wrong, struck: true),
          const SizedBox(height: 6),
          line(LucideIcons.check, AppColors.success, right),
        ],
      ),
    );
  }
}
