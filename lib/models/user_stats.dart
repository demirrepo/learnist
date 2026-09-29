import 'user_progress.dart';

/// The Home and Profile statistics from the `get_user_stats` database
/// function.
///
/// Parsing never throws: a missing or malformed value reads as 0, so a
/// student with no scores yet sees zeros rather than an error.
class UserStats {
  const UserStats({
    this.lessonsMastered = 0,
    this.currentLessonMastery = 0,
    this.overallAverage = 0,
    this.trackedMistakes = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const {};
    return UserStats(
      lessonsMastered: _parseInt(
        data['lessons_mastered'],
      ).clamp(0, UserProgress.lastLesson),
      currentLessonMastery: _parseInt(
        data['current_lesson_mastery'],
      ).clamp(0, 100),
      overallAverage: _parseInt(data['overall_average']).clamp(0, 100),
      trackedMistakes: _parseInt(data['tracked_mistakes']).clamp(0, 1 << 31),
    );
  }

  /// Lessons completed so far: the current lesson minus one.
  final int lessonsMastered;

  /// Section average (0–100) of the current lesson, rounded down.
  final int currentLessonMastery;

  /// Mean section average (0–100) of the completed lessons, rounded down.
  final int overallAverage;

  /// Reading and listening questions still answered wrong.
  final int trackedMistakes;

  static int _parseInt(Object? value) => switch (value) {
    int v => v,
    num v when v.isFinite => v.floor(),
    String v => int.tryParse(v.trim()) ?? 0,
    _ => 0,
  };
}
