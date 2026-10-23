import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../models/lesson_model.dart';
import '../../theme/app_theme.dart';
import 'ai_graded_task.dart';
import 'ask_ai_dialog.dart';
import 'lesson_common.dart';

/// Used when the instruction names no "(80–100 words)" range.
const _defaultWords = (min: 80, max: 120);

final _wordRangePattern = RegExp(r'(\d+)\s*[–-]\s*(\d+)\s+words');

/// The word range the instruction asks for, e.g. "(80–100 words)".
({int min, int max}) _wordRange(String prompt) {
  final match = _wordRangePattern.firstMatch(prompt);
  if (match == null) return _defaultWords;
  return (min: int.parse(match[1]!), max: int.parse(match[2]!));
}

/// The writing task, graded by the AI as the lesson's `writing` section.
class WritingTab extends StatelessWidget {
  const WritingTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final prompt = lesson.writingPrompt;
    if (prompt == null) {
      return LessonTabBody(
        children: [LessonNotice(context.l10n.lessonNoWriting)],
      );
    }
    final words = _wordRange(prompt);

    return LessonTabBody(
      children: [
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LessonPrompt(
                tagIcon: LucideIcons.pencil,
                tag: context.l10n.lessonTagWritingTask,
                title: lesson.writingTitle ?? lesson.title,
                body: prompt,
              ),
              const SizedBox(height: 18),
              AiGradedTask(
                lessonNumber: lesson.lessonNumber,
                section: 'writing',
                buttonLabel: context.l10n.lessonAssessWriting,
                hint: context.l10n.lessonWritingHint,
                minLines: 10,
                maxLines: 20,
                evaluate: (ai, answer) => ai.evaluateWriting(answer, prompt),
                fieldFooter: (answer) => _WordCount(answer, range: words),
                onAskAi:
                    () => showAskAiDialog(
                      context,
                      lesson: lesson,
                      section: AskAiSection.writing,
                    ),
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
  const _WordCount(this.text, {required this.range});

  final String text;
  final ({int min, int max}) range;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    final count = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    final inRange = count >= range.min && count <= range.max;

    return Text(
      context.l10n.lessonWordCount(count, range.min, range.max),
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
    final l10n = context.l10n;
    final lenses = [
      (level: 'A1', focus: l10n.lessonLensA1),
      (level: 'A2', focus: l10n.lessonLensA2),
      (level: 'B1', focus: l10n.lessonLensB1),
      (level: 'B2', focus: l10n.lessonLensB2),
    ];

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
                  l10n.lessonCefrLenses,
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
            l10n.lessonCefrLensesCaption,
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          for (final lens in lenses) ...[
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
