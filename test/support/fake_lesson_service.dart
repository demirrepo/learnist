import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:learnist/models/lesson_model.dart';
import 'package:learnist/services/lesson_service.dart';

/// The seeded curriculum; same snake_case keys as the `lessons` rows.
final seedLessons = [
  for (final row
      in jsonDecode(File('lessons_seed_data.json').readAsStringSync()) as List)
    Lesson.fromJson(row as Map<String, dynamic>),
];

/// Serves [lessons] (the seed data by default) without touching Supabase.
///
/// Set [error] to make every call fail, or [pending] to hold calls until it
/// completes.
class FakeLessonService implements LessonService {
  FakeLessonService({List<Lesson>? lessons, this.error, this.pending})
    : lessons = lessons ?? seedLessons;

  final List<Lesson> lessons;
  Object? error;
  Completer<void>? pending;
  int fetchCount = 0;

  Future<void> _gate() async {
    fetchCount++;
    if (pending case final completer?) await completer.future;
    if (error case final error?) throw error;
  }

  @override
  Future<List<Lesson>> getAllLessons() async {
    await _gate();
    return lessons;
  }

  @override
  Future<Lesson> getLessonByNumber(int lessonNumber) async {
    await _gate();
    return lessons.firstWhere(
      (lesson) => lesson.lessonNumber == lessonNumber,
      orElse: () => throw LessonNotFoundException(lessonNumber),
    );
  }
}
