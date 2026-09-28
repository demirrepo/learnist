import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../theme/app_theme.dart';
import 'ai_graded_task.dart';
import 'lesson_common.dart';

const _noRulesMessage = "Ushbu darsda grammatika qoidalari yo'q.";

/// The lesson's grammar rule and a practical task that Gemini scores as
/// the lesson's `grammar` section.
class GrammarTab extends StatelessWidget {
  const GrammarTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final rules = lesson.grammarRules;

    return LessonTabBody(
      children: [
        if (rules == null)
          const LessonNotice(_noRulesMessage)
        else
          _RulesCard(
            focus: lesson.grammarFocus,
            rules: rules,
            isGeneralGuide: lesson.isFallbackGrammarRule,
          ),
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LessonPrompt(
                tagIcon: LucideIcons.target,
                tag: 'Practical task',
                title: 'Use it in context',
                body:
                    'Write at least three sentences of your own about '
                    '"${lesson.title}". Use ${lesson.grammarFocus} naturally.',
              ),
              const SizedBox(height: 18),
              AiGradedTask(
                lessonNumber: lesson.lessonNumber,
                section: 'grammar',
                buttonLabel: 'Analyze my answer',
                hint: 'Write your answer here…',
                evaluate:
                    (gemini, answer) =>
                        gemini.evaluateGrammar(answer, lesson.grammarFocus),
                onAskAi: () => showComingSoon(context, 'Ask AI'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({
    required this.focus,
    required this.rules,
    required this.isGeneralGuide,
  });

  final String focus;
  final String rules;

  /// The lesson had no rule of its own; this is the category's guide.
  final bool isGeneralGuide;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LessonTag(icon: LucideIcons.bookMarked, label: 'Grammar rule'),
          const SizedBox(height: 14),
          Text(focus, style: lessonHeadingStyle),
          if (isGeneralGuide) ...[
            const SizedBox(height: 6),
            Text(
              'Umumiy qoida',
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.hint,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            rules,
            style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
