import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../models/user_progress.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';
import 'ai_graded_task.dart';
import 'complete_lesson_button.dart';
import 'lesson_common.dart';

const _noSpeakingMessage = "Ushbu darsda gapirish mashqi yo'q.";

/// The last tab, so it ends with "Darsni yakunlash" on the student's
/// current lesson. Reviewing an earlier lesson, or while progress is still
/// loading, shows no button. Lesson 52 has nothing left to unlock.
class SpeakingTab extends ConsumerWidget {
  const SpeakingTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLesson = ref.watch(userProgressProvider).value?.currentLesson;
    final number = lesson.lessonNumber;
    final complete = [
      if (number == currentLesson && number < UserProgress.lastLesson)
        CompleteLessonButton(lessonNumber: number),
    ];

    final prompt = lesson.speakingPrompt;
    if (prompt == null) {
      return LessonTabBody(
        children: [const LessonNotice(_noSpeakingMessage), ...complete],
      );
    }

    return LessonTabBody(
      children: [
        LessonCard(
          child: LessonPrompt(
            tagIcon: LucideIcons.mic,
            tag: 'Speaking task',
            title: lesson.title,
            body: prompt,
          ),
        ),
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Transcript',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              AiGradedTask(
                lessonNumber: number,
                section: 'speaking',
                buttonLabel: 'Assess speaking',
                hint: 'Record your answer, or type what you said here…',
                minLines: 5,
                isSpeakingTask: true,
                evaluate: (ai, answer) => ai.evaluateSpeaking(answer, prompt),
              ),
            ],
          ),
        ),
        ...complete,
      ],
    );
  }
}
