/// A row of `public.user_mistakes`: one reading or listening quiz question
/// the student keeps getting wrong.
class TrackedMistake {
  const TrackedMistake({
    required this.lessonNumber,
    required this.section,
    required this.questionIndex,
    required this.frequency,
  });

  /// Null when [row] is missing a field or has one out of range.
  static TrackedMistake? tryParse(Map<String, dynamic> row) {
    final lesson = _parseInt(row['lesson_number']);
    final section = row['section'];
    final index = _parseInt(row['question_index']);
    final frequency = _parseInt(row['frequency']);
    if (lesson == null ||
        lesson < 1 ||
        section is! String ||
        section.isEmpty ||
        index == null ||
        index < 0 ||
        frequency == null ||
        frequency < 1) {
      return null;
    }
    return TrackedMistake(
      lessonNumber: lesson,
      section: section,
      questionIndex: index,
      frequency: frequency,
    );
  }

  /// Mistakes made at least this often are recurring and appear on the
  /// map; one slip is not a weakness.
  static const recurringThreshold = 2;

  /// From this frequency a mistake is marked red, below it yellow.
  static const highThreshold = 4;

  final int lessonNumber;

  /// 'reading' or 'listening'.
  final String section;

  /// 0-based position of the question in the section's quiz.
  final int questionIndex;

  /// How many graded attempts got this question wrong.
  final int frequency;

  static int? _parseInt(Object? value) => switch (value) {
    int v => v,
    num v when v == v.roundToDouble() => v.toInt(),
    String v => int.tryParse(v.trim()),
    _ => null,
  };
}
