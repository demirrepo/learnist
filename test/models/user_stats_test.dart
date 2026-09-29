import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/user_stats.dart';

void main() {
  test('reads get_user_stats', () {
    final stats = UserStats.fromJson({
      'lessons_mastered': 4,
      'current_lesson_mastery': 63,
      'overall_average': 87,
      'tracked_mistakes': 5,
    });
    expect(stats.lessonsMastered, 4);
    expect(stats.currentLessonMastery, 63);
    expect(stats.overallAverage, 87);
    expect(stats.trackedMistakes, 5);
  });

  test('a missing or malformed value reads as 0', () {
    for (final json in [
      null,
      <String, dynamic>{},
      {
        'lessons_mastered': 'many',
        'current_lesson_mastery': null,
        'overall_average': double.nan,
        'tracked_mistakes': [1],
      },
    ]) {
      final stats = UserStats.fromJson(json);
      expect(stats.lessonsMastered, 0, reason: '$json');
      expect(stats.currentLessonMastery, 0, reason: '$json');
      expect(stats.overallAverage, 0, reason: '$json');
      expect(stats.trackedMistakes, 0, reason: '$json');
    }
  });

  test('rounds down and keeps values in range', () {
    final stats = UserStats.fromJson({
      'lessons_mastered': 60,
      'current_lesson_mastery': 79.9,
      'overall_average': -5,
      'tracked_mistakes': '12',
    });
    expect(stats.lessonsMastered, 52);
    expect(stats.currentLessonMastery, 79);
    expect(stats.overallAverage, 0);
    expect(stats.trackedMistakes, 12);
  });
}
