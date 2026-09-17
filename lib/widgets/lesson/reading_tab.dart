import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'lesson_quiz.dart';

// Placeholder content until lessons come from the backend.
const _passage =
    'Maya is taking part in an international summer school in Tashkent. '
    'She is 19 and she is from Kraków, Poland. Her roommate is Dilnoza. '
    'Dilnoza is from Samarkand and she is a medicine student. The other '
    'students in their group are from Korea, Brazil and Egypt. Their teacher '
    'is Mr Karimov. He is friendly and his classes are fun. Maya is happy, '
    'but she is a little nervous about the first test on Friday.';

const _questions = [
  QuizQuestion(
    prompt: 'Where is Maya from?',
    options: ['Tashkent', 'Kraków', 'Samarkand', 'Cairo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    prompt: 'Who is Dilnoza?',
    options: [
      "Maya's teacher",
      "Maya's sister",
      "Maya's roommate",
      'A student from Egypt',
    ],
    correctIndex: 2,
  ),
];

const _vocabulary = [
  (word: 'take part in', translation: 'qatnashmoq'),
  (word: 'roommate', translation: 'xonadosh'),
  (word: 'friendly', translation: 'samimiy, do\'stona'),
  (word: 'nervous', translation: 'hayajonlangan'),
];

class ReadingTab extends StatelessWidget {
  const ReadingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonTabBody(
      children: [
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LessonTag(icon: LucideIcons.bookOpen, label: 'Reading'),
              const SizedBox(height: 14),
              Text('A new start', style: lessonHeadingStyle),
              const SizedBox(height: 10),
              Text(
                _passage,
                style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const LessonQuiz(questions: _questions),
        const _VocabularyCard(),
      ],
    );
  }
}

/// The web sidebar's "Lug'at" panel, collapsed under the quiz on mobile.
class _VocabularyCard extends StatelessWidget {
  const _VocabularyCard();

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      padding: EdgeInsets.zero,
      child: Theme(
        // Drop the divider lines ExpansionTile draws when expanded.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(borderRadius: lessonCardRadius),
          collapsedShape:
              const RoundedRectangleBorder(borderRadius: lessonCardRadius),
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
            '${_vocabulary.length} key words',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          children: [
            for (var i = 0; i < _vocabulary.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _vocabulary[i].word,
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _vocabulary[i].translation,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
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
