import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';

class GrammarTab extends StatelessWidget {
  const GrammarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonTabBody(
      children: [
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LessonPrompt(
                tagIcon: LucideIcons.target,
                tag: 'Practical task',
                title: 'Introduce yourself',
                body: 'You have just joined a new university English group. '
                    'Introduce yourself to your classmates: say your name, '
                    'where you are from and what you study. Use am / is / are '
                    'in at least three sentences.',
              ),
              const SizedBox(height: 18),
              const LessonTextField(hint: 'Write your answer here…'),
              const SizedBox(height: 16),
              LessonActionRow(
                primaryLabel: 'Analyze my answer',
                onPrimary: () => showComingSoon(context, 'Answer analysis'),
                onAskAi: () => showComingSoon(context, 'Ask AI'),
              ),
            ],
          ),
        ),
        const _BestScore(percent: 85),
      ],
    );
  }
}

class _BestScore extends StatelessWidget {
  const _BestScore({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Best score: $percent%',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: lessonCardRadius,
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.trophy, color: AppColors.successDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Best score',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successDark,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.successDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
