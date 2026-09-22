import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/user_progress.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';

void main() {
  final rows =
      (jsonDecode(File('assets/data/checkup_questions.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();

  test('has exactly 30 questions with ids 1–30 in order', () {
    expect(rows, hasLength(30));
    expect(rows.map((r) => r['id']), List.generate(30, (i) => i + 1));
  });

  test('has 5 questions per CEFR level, A1 to C2 in order', () {
    expect(rows.map((r) => r['level']), [
      for (final level in UserProgress.cefrLevels) ...List.filled(5, level),
    ]);
  });

  test('every question is scoreable and has distinct options', () {
    for (final row in rows) {
      expect(QuizQuestion.tryParse(row), isNotNull, reason: 'id ${row['id']}');
      final options = row['options'] as List;
      expect(
        options.toSet(),
        hasLength(options.length),
        reason: '${row['id']}',
      );
      expect(row['question'], contains('___'), reason: '${row['id']}');
      expect(row.keys.toSet(), {
        'id',
        'level',
        'question',
        'options',
        'answer_index',
      });
    }
  });

  test('question texts are unique', () {
    final questions = rows.map((r) => r['question']).toList();
    expect(questions.toSet(), hasLength(questions.length));
  });
}
