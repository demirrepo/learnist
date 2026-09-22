import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson_model.dart';
import 'supabase_service.dart' show isNetworkError;

final lessonServiceProvider = Provider<LessonService>((ref) => LessonService());

/// Reads the `lessons` table. RLS lets signed-in users read it; nothing here
/// writes, since lessons are seeded with the service_role key.
///
/// Failures are logged in debug builds and rethrown, so callers can tell an
/// empty result apart from a network or permission error.
class LessonService {
  LessonService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const _table = 'lessons';

  /// Listed explicitly so a renamed or dropped column fails the query
  /// instead of silently parsing as null.
  static const _columns =
      'lesson_number, original_number, semester, title, grammar_focus, '
      'cefr_level, topic, task_meta, grammar_rules, grammar_rules_source, '
      'reading_passage, reading_format, reading_vocabulary, reading_questions, '
      'listening_transcript, listening_format, listening_speakers, '
      'listening_questions, writing_prompt, speaking_prompt';

  /// PostgREST's code when `.single()` matches no rows.
  static const _noRowsCode = 'PGRST116';

  /// Every lesson, ordered 1 – 52.
  Future<List<Lesson>> getAllLessons() async {
    try {
      final rows = await _supabase
          .from(_table)
          .select(_columns)
          .order('lesson_number', ascending: true);
      return [for (final row in rows) Lesson.fromJson(row)];
    } on PostgrestException catch (error, stackTrace) {
      _log('getAllLessons', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _log('getAllLessons', error, stackTrace);
      rethrow;
    }
  }

  /// Throws [LessonNotFoundException] when no lesson has [lessonNumber].
  Future<Lesson> getLessonByNumber(int lessonNumber) async {
    try {
      final row =
          await _supabase
              .from(_table)
              .select(_columns)
              .eq('lesson_number', lessonNumber)
              .single();
      return Lesson.fromJson(row);
    } on PostgrestException catch (error, stackTrace) {
      _log('getLessonByNumber($lessonNumber)', error, stackTrace);
      if (error.code == _noRowsCode) {
        throw LessonNotFoundException(lessonNumber);
      }
      rethrow;
    } catch (error, stackTrace) {
      _log('getLessonByNumber($lessonNumber)', error, stackTrace);
      rethrow;
    }
  }
}

/// No row in `lessons` has the requested number, or RLS hid it (e.g. the
/// user is signed out).
class LessonNotFoundException implements Exception {
  const LessonNotFoundException(this.lessonNumber);

  final int lessonNumber;

  @override
  String toString() => 'LessonNotFoundException: lesson $lessonNumber';
}

/// User-facing Uzbek message for a failed lesson load.
String lessonLoadErrorMessage(Object error) {
  if (isNetworkError(error)) {
    return "Internet aloqasi yo'q. Tarmoqni tekshirib, qayta urinib ko'ring.";
  }
  if (error is LessonNotFoundException) return 'Dars topilmadi.';
  if (error is PostgrestException) {
    return "Darslarni yuklab bo'lmadi. Birozdan so'ng qayta urinib ko'ring.";
  }
  return "Nimadir xato ketdi. Iltimos, qayta urinib ko'ring.";
}

void _log(String action, Object error, StackTrace stackTrace) {
  if (!kDebugMode) return;
  debugPrint('[Lessons] $action failed: ${error.runtimeType}: $error');
  debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
}
