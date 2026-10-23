import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../models/lesson_model.dart';
import '../../models/vocabulary_item.dart';
import '../../services/progress_service.dart';
import '../../services/pronunciation_service.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'lesson_quiz.dart';
import 'section_score.dart';

/// The reading passage and its quiz, whose score is saved as the lesson's
/// `reading` section.
class ReadingTab extends ConsumerWidget {
  const ReadingTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passage = lesson.readingPassage;
    final questions = QuizQuestion.listFrom(lesson.readingQuestions);
    final vocabulary = VocabularyItem.listFrom(lesson.readingVocabulary);

    return LessonTabBody(
      children: [
        if (passage == null)
          LessonNotice(context.l10n.lessonNoReading)
        else
          LessonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonTag(
                  icon: LucideIcons.bookOpen,
                  label: context.l10n.lessonTabReading,
                ),
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
                (score, wrongIndexes) => saveQuizResultOrWarn(
                  progress: ref.read(progressServiceProvider),
                  messenger: ScaffoldMessenger.of(context),
                  lessonNumber: lesson.lessonNumber,
                  section: 'reading',
                  score: score,
                  wrongIndexes: wrongIndexes,
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

  final List<VocabularyItem> items;

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
            context.l10n.lessonVocabulary,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            context.l10n.lessonKeyWords(items.length),
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.border),
              _VocabularyRow(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// A word with its IPA, its meaning in the interface language, its English
/// definition and a button that reads it aloud.
class _VocabularyRow extends ConsumerWidget {
  const _VocabularyRow({required this.item});

  final VocabularyItem item;

  Future<void> _speak(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(pronunciationServiceProvider).speak(item.word);
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] speaking "${item.word}": $error');
      showLessonError(messenger, l10n.vocabularySpeakError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phonetic = item.phonetic;
    final definition = item.definition;
    final translation = item.translationFor(
      Localizations.localeOf(context).languageCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.word,
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (phonetic != null)
                      // The platform font: Manrope lacks the IPA symbols.
                      Text(
                        phonetic,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.hint,
                        ),
                      ),
                  ],
                ),
                if (translation != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    translation,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (definition != null) ...[
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
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => unawaited(_speak(context, ref)),
            tooltip: context.l10n.vocabularyListen(item.word),
            color: AppColors.primary,
            style: IconButton.styleFrom(backgroundColor: AppColors.primarySoft),
            icon: const Icon(LucideIcons.volume2, size: 20),
          ),
        ],
      ),
    );
  }
}
