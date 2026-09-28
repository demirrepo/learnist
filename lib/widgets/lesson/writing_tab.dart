import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../theme/app_theme.dart';
import 'ai_graded_task.dart';
import 'lesson_common.dart';

const _noWritingMessage = "Ushbu darsda yozish mashqi yo'q.";

const _lenses = [
  (level: 'A1', focus: "Short, correct sentences using the lesson's grammar."),
  (level: 'A2', focus: 'Link ideas with and, but and because.'),
  (level: 'B1', focus: 'Add details and reasons in clear paragraphs.'),
  (level: 'B2', focus: 'Vary your vocabulary and sentence structure.'),
];

const _minWords = 80;
const _maxWords = 120;

/// The writing task, graded by Gemini as the lesson's `writing` section.
class WritingTab extends StatelessWidget {
  const WritingTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final prompt = lesson.writingPrompt;
    if (prompt == null) {
      return const LessonTabBody(children: [LessonNotice(_noWritingMessage)]);
    }

    return LessonTabBody(
      children: [
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LessonPrompt(
                tagIcon: LucideIcons.pencil,
                tag: 'Writing task',
                title: lesson.title,
                body: prompt,
              ),
              const SizedBox(height: 18),
              AiGradedTask(
                lessonNumber: lesson.lessonNumber,
                section: 'writing',
                buttonLabel: 'Assess my writing',
                hint: 'Write your text here…',
                minLines: 10,
                maxLines: 20,
                evaluate:
                    (gemini, answer) => gemini.evaluateWriting(answer, prompt),
                fieldFooter: _WordCount.new,
                onAskAi: () => showComingSoon(context, 'Ask AI'),
              ),
            ],
          ),
        ),
        const _CefrLenses(),
      ],
    );
  }
}

class _WordCount extends StatelessWidget {
  const _WordCount(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    final count = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    final inRange = count >= _minWords && count <= _maxWords;

    return Text(
      '$count / $_minWords–$_maxWords words',
      textAlign: TextAlign.end,
      style: GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: inRange ? AppColors.success : AppColors.hint,
      ),
    );
  }
}

class _CefrLenses extends StatelessWidget {
  const _CefrLenses();

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.layers, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CEFR lenses',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your writing is assessed through these levels.',
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          for (final lens in _lenses) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    lens.level,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lens.focus,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
