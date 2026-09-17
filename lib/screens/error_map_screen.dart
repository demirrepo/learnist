import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../router.dart';
import '../theme/app_theme.dart';
import '../widgets/error_map/error_pattern_card.dart';

// Placeholder mistake groups until AI feedback is stored. All point at
// Lesson 1, the only lesson screen that exists so far.
const _patterns = [
  ErrorPattern(
    rule: 'Subject pronouns: am / is / are',
    example: 'She are a student.',
    correction: 'She is a student.',
    mistakeCount: 4,
    lessonLabel: 'Lesson 1: Hello, everybody!',
  ),
  ErrorPattern(
    rule: 'Questions with to be: Are you…? / Is he…?',
    example: 'You are from Tashkent?',
    correction: 'Are you from Tashkent?',
    mistakeCount: 3,
    lessonLabel: 'Lesson 1: Hello, everybody!',
  ),
  ErrorPattern(
    rule: 'Contractions: I’m / you’re / it’s',
    example: 'Im a first-year student.',
    correction: 'I’m a first-year student.',
    mistakeCount: 2,
    lessonLabel: 'Lesson 1: Hello, everybody!',
  ),
  // A single slip — filtered out because it isn't a pattern yet.
  ErrorPattern(
    rule: 'Articles: a / an',
    example: 'He is a engineer.',
    correction: 'He is an engineer.',
    mistakeCount: 1,
    lessonLabel: 'Lesson 1: Hello, everybody!',
  ),
];

/// Recurring patterns only, most frequent first.
@visibleForTesting
List<ErrorPattern> recurringPatterns(List<ErrorPattern> patterns) =>
    patterns.where((pattern) => pattern.isRecurring).toList()
      ..sort((a, b) => b.mistakeCount.compareTo(a.mistakeCount));

class ErrorMapScreen extends StatelessWidget {
  const ErrorMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patterns = recurringPatterns(_patterns);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Xatolar xaritasi',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _Intro(),
          const SizedBox(height: 20),
          if (patterns.isEmpty)
            const _EmptyState()
          else
            for (var i = 0; i < patterns.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              ErrorPatternCard(
                pattern: patterns[i],
                onReview: () => context.push(AppRoutes.lessonDetail),
              ),
            ],
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final legendStyle = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
    );

    Widget legend(ErrorSeverity severity, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: severity.color,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: legendStyle),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Takrorlanayotgan xatolaringiz qoidalar bo\'yicha guruhlangan. '
          'Kamida ${ErrorPattern.recurringThreshold} marta uchragan xatolar '
          "ko'rsatiladi — mavzuni qayta o'rganish uchun kartani bosing.",
          style: GoogleFonts.manrope(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            legend(ErrorSeverity.high, "Ko'p takrorlangan (4+)"),
            legend(ErrorSeverity.medium, "O'rtacha (2–3)"),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            size: 40,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            "Takrorlanayotgan xatolar yo'q. Ajoyib!",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
