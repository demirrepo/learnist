import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data/mistakes_metadata.dart';
import '../models/tracked_mistake.dart';
import '../router.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_map/error_pattern_card.dart';
import '../widgets/load_problem_view.dart';

const _sectionNames = {'reading': 'Reading', 'listening': 'Listening'};

/// Card content for a tracked mistake, from [mistakesMetadata]. Mistakes
/// without an entry are named after their quiz question instead.
@visibleForTesting
ErrorPattern errorPatternFrom(TrackedMistake mistake) {
  final metadata = mistakeMetadataFor(
    mistake.lessonNumber,
    mistake.section,
    mistake.questionIndex,
  );
  final section = _sectionNames[mistake.section] ?? mistake.section;
  return ErrorPattern(
    rule: metadata?.title ?? '$section: ${mistake.questionIndex + 1}-savol',
    example: metadata?.wrongText,
    correction: metadata?.rightText,
    mistakeCount: mistake.frequency,
    lessonLabel: 'Lesson ${mistake.lessonNumber}',
    lessonNumber: mistake.lessonNumber,
  );
}

/// Recurring patterns only, most frequent first.
///
/// The server already filters and sorts; this keeps the map right even if
/// a row slips through.
@visibleForTesting
List<ErrorPattern> recurringPatterns(List<ErrorPattern> patterns) =>
    patterns.where((pattern) => pattern.isRecurring).toList()
      ..sort((a, b) => b.mistakeCount.compareTo(a.mistakeCount));

/// "Xatolar xaritasi": the student's unresolved quiz mistakes made at
/// least twice, from [recurringMistakesProvider].
class ErrorMapScreen extends ConsumerWidget {
  const ErrorMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mistakes = ref.watch(recurringMistakesProvider);

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
          ...switch (mistakes) {
            AsyncData(:final value) => _cards(context, value),
            AsyncError(:final error) => [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: LoadProblemView(
                  message: checkupErrorMessage(error),
                  onRetry: () => ref.invalidate(recurringMistakesProvider),
                ),
              ),
            ],
            _ => const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          },
        ],
      ),
    );
  }

  List<Widget> _cards(BuildContext context, List<TrackedMistake> mistakes) {
    final patterns = recurringPatterns([
      for (final mistake in mistakes) errorPatternFrom(mistake),
    ]);
    if (patterns.isEmpty) return const [_EmptyState()];
    return [
      for (var i = 0; i < patterns.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        ErrorPatternCard(
          pattern: patterns[i],
          onReview:
              () => context.push(
                AppRoutes.lessonDetailFor(patterns[i].lessonNumber),
              ),
        ),
      ],
    ];
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
          'Testlarda qayta-qayta xato qilayotgan savollaringiz. '
          'Kamida ${TrackedMistake.recurringThreshold} marta takrorlangan '
          "xatolar ko'rsatiladi — mavzuni qayta o'rganish uchun kartani bosing.",
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
            "Ajoyib! Hozircha takrorlangan xatolar yo'q",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Testlarda bir xil savolda ikki marta xato qilsangiz, "
            "u shu yerda paydo bo'ladi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
