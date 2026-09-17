import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

// Placeholder course content until it comes from the backend.
const _steps = [
  AiCourseStep(
    title: 'Prompt nima?',
    description:
        'A prompt is the message you send to an AI. The clearer it '
        'is, the more useful the answer.',
    example: 'Explain the present perfect.',
  ),
  AiCourseStep(
    title: 'Role',
    description: 'Tell the AI who to be, so it answers like an expert.',
    example: 'You are an IELTS speaking examiner.',
  ),
  AiCourseStep(
    title: 'Task',
    description: 'Say exactly what you want it to do.',
    example: 'Check my essay for tense mistakes.',
  ),
  AiCourseStep(
    title: 'Level',
    description: 'Give your English level so the answer fits you.',
    example: "I'm a B1 learner. Use simple words.",
  ),
  AiCourseStep(
    title: 'Context',
    description: 'Share the background: the text, the question, your goal.',
    example: 'This is question 4 from a reading test.',
  ),
  AiCourseStep(
    title: 'Format',
    description:
        'Ask for the shape of the answer: a list, a table or a '
        'short paragraph.',
    example: 'Answer in 3 bullet points.',
  ),
  AiCourseStep(
    title: 'Examples & Tone',
    description: 'Show an example and choose the tone you want.',
    example: 'Be friendly and give one example sentence.',
  ),
];

/// The seven-step prompt course as numbered cards.
class AiCourseList extends StatelessWidget {
  const AiCourseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiLabSectionHeader(
          title: 'AI course',
          subtitle: '${_steps.length} short steps to a strong prompt.',
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _steps.length,
          itemBuilder:
              (context, index) => Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                child: AiCourseStepCard(number: index + 1, step: _steps[index]),
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
