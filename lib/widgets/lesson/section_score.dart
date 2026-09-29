import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';

const saveScoreErrorMessage = "Ball saqlanmadi. Iltimos qayta urinib ko'ring.";

/// Red snackbar for a lesson task that failed.
void showLessonError(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(backgroundColor: AppColors.danger, content: Text(message)),
    );
}

/// Saves a graded reading or listening quiz: its score as the lesson's
/// [section] score, then its [wrongIndexes] as tracked mistakes. A failed
/// score shows [saveScoreErrorMessage]; a failed mistake update is only
/// logged, since the student has nothing to retry.
Future<void> saveQuizResultOrWarn({
  required ProgressService progress,
  required ScaffoldMessengerState messenger,
  required int lessonNumber,
  required String section,
  required int score,
  required List<int> wrongIndexes,
}) async {
  await saveSectionScoreOrWarn(
    progress: progress,
    messenger: messenger,
    lessonNumber: lessonNumber,
    section: section,
    score: score,
  );
  try {
    await progress.saveMistakes(lessonNumber, section, wrongIndexes);
  } catch (error) {
    if (kDebugMode) debugPrint('[Lesson] saving $section mistakes: $error');
  }
}

/// Saves the lesson's [section] score (0–100); a failure shows
/// [saveScoreErrorMessage] instead of throwing.
///
/// Takes the service and messenger rather than a context so callers can
/// read them before an await and still save after the student leaves.
Future<void> saveSectionScoreOrWarn({
  required ProgressService progress,
  required ScaffoldMessengerState messenger,
  required int lessonNumber,
  required String section,
  required int score,
}) async {
  try {
    await progress.saveSectionScore(lessonNumber, section, score);
  } catch (error) {
    if (kDebugMode) debugPrint('[Lesson] saving the $section score: $error');
    showLessonError(messenger, saveScoreErrorMessage);
  }
}
