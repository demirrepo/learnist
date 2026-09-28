import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'lesson_quiz.dart';
import 'section_score.dart';

const _noReadingMessage = "Ushbu darsda o'qish mashqi yo'q.";

typedef _VocabularyItem = ({String word, String? definition});

/// `{word, definition}` items from the JSONB column; entries without a word
/// are skipped.
List<_VocabularyItem> _parseVocabulary(List<dynamic> raw) {
  String? text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  return [
    for (final item in raw)
      if (item is Map)
        if (text(item['word']) case final word?)
          (word: word, definition: text(item['definition'])),
  ];
}

/// The reading passage and its quiz, whose score is saved as the lesson's
/// `reading` section.
class ReadingTab extends ConsumerWidget {
  const ReadingTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passage = lesson.readingPassage;
    final questions = QuizQuestion.listFrom(lesson.readingQuestions);
    final vocabulary = _parseVocabulary(lesson.readingVocabulary);

    return LessonTabBody(
      children: [
        if (passage == null)
          const LessonNotice(_noReadingMessage)
        else
          LessonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LessonTag(icon: LucideIcons.bookOpen, label: 'Reading'),
                const SizedBox(height: 14),
                Text(lesson.title, style: lessonHeadingStyle),
                const SizedBox(height: 10),
                Text(
                  passage,
                  style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        // A quiz without its passage can't be answered.
        if (passage != null && questions.isNotEmpty)
          LessonQuiz(
            key: ValueKey('reading-quiz-${lesson.lessonNumber}'),
            questions: questions,
            onScored:
                (score) => saveSectionScoreOrWarn(
                  progress: ref.read(progressServiceProvider),
                  messenger: ScaffoldMessenger.of(context),
                  lessonNumber: lesson.lessonNumber,
                  section: 'reading',
                  score: score,
                ),
          ),
        if (vocabulary.isNotEmpty) _VocabularyCard(items: vocabulary),
      ],
    );
  }
}

/// The web sidebar's "Lug'at" panel, collapsed under the quiz on mobile.
class _VocabularyCard extends StatelessWidget {
  const _VocabularyCard({required this.items});

  final List<_VocabularyItem> items;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      padding: EdgeInsets.zero,
      child: Theme(
        // Drop the divider lines ExpansionTile draws when expanded.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(borderRadius: lessonCardRadius),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: lessonCardRadius,
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          leading: const Icon(LucideIcons.languages, color: AppColors.primary),
          title: Text(
            "Lug'at",
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${items.length} key words',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].word,
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (items[i].definition case final definition?) ...[
                      const SizedBox(height: 2),
                      Text(
                        definition,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
