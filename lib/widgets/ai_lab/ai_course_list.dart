import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import 'ai_lab_common.dart';

class AiCourseStep {
  const AiCourseStep({
    required this.title,
    required this.description,
    required this.example,
  });

  final String title;
  final String description;

  /// A sample prompt fragment that applies the step.
  final String example;
}

/// Placeholder course content until it comes from the backend. The
/// examples are English prompts, so they stay English in every language.
List<AiCourseStep> _steps(AppLocalizations l10n) => [
  AiCourseStep(
    title: l10n.aiStepWhatTitle,
    description: l10n.aiStepWhatBody,
    example: 'Explain the present perfect.',
  ),
  AiCourseStep(
    title: l10n.promptPartRole,
    description: l10n.aiStepRoleBody,
    example: 'You are an IELTS speaking examiner.',
  ),
  AiCourseStep(
    title: l10n.promptPartTask,
    description: l10n.aiStepTaskBody,
    example: 'Check my essay for tense mistakes.',
  ),
  AiCourseStep(
    title: l10n.promptPartLevel,
    description: l10n.aiStepLevelBody,
    example: "I'm a B1 learner. Use simple words.",
  ),
  AiCourseStep(
    title: l10n.promptPartContext,
    description: l10n.aiStepContextBody,
    example: 'This is question 4 from a reading test.',
  ),
  AiCourseStep(
    title: l10n.promptPartFormat,
    description: l10n.aiStepFormatBody,
    example: 'Answer in 3 bullet points.',
  ),
  AiCourseStep(
    title: l10n.aiStepExamplesTitle,
    description: l10n.aiStepExamplesBody,
    example: 'Be friendly and give one example sentence.',
  ),
];

/// The seven-step prompt course as numbered cards.
class AiCourseList extends StatelessWidget {
  const AiCourseList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiLabSectionHeader(
          title: l10n.aiCourseTitle,
          subtitle: l10n.aiCourseSubtitle(steps.length),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: steps.length,
          itemBuilder:
              (context, index) => Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                child: AiCourseStepCard(number: index + 1, step: steps[index]),
              ),
        ),
      ],
    );
  }
}

class AiCourseStepCard extends StatelessWidget {
  const AiCourseStepCard({super.key, required this.number, required this.step});

  final int number;
  final AiCourseStep step;

  @override
  Widget build(BuildContext context) {
    return AiLabCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$number',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '"${step.example}"',
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
