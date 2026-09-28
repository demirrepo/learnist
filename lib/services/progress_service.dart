import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkup.dart';
import '../models/user_progress.dart';
import '../models/user_stats.dart';
import 'supabase_service.dart' show isNetworkError, supabaseServiceProvider;

final progressServiceProvider = Provider<ProgressService>((ref) {
  final service = ProgressService();
  ref.onDispose(service.dispose);
  return service;
});

/// These screens have their own "Qayta urinish" button; Riverpod's
/// automatic retries would only delay the error state.
Duration? _noRetry(int retryCount, Object error) => null;

/// Refetch whenever the auth service notifies (sign-in, sign-out, a
/// different user), so one user's data never shows for another.
void _refetchOnAuthChange(Ref ref) {
  final auth = ref.watch(supabaseServiceProvider);
  void refresh() => ref.invalidateSelf();
  auth.addListener(refresh);
  ref.onDispose(() => auth.removeListener(refresh));
}

/// The signed-in user's `user_progress` row, or defaults before their first
/// check-up.
final userProgressProvider = FutureProvider<UserProgress>((ref) {
  _refetchOnAuthChange(ref);
  return ref.watch(progressServiceProvider).fetchProgress();
}, retry: _noRetry);

/// The Home and Profile statistics. Refetched after every score, mistake
/// or lesson the service saves, as well as on auth changes.
final userStatsProvider = FutureProvider<UserStats>((ref) {
  _refetchOnAuthChange(ref);
  final service = ref.watch(progressServiceProvider);
  void refresh() => ref.invalidateSelf();
  service.addListener(refresh);
  ref.onDispose(() => service.removeListener(refresh));
  return service.fetchStats();
}, retry: _noRetry);

/// Past check-ups, oldest first, for the growth chart.
final checkupHistoryProvider = FutureProvider<List<CheckupHistoryEntry>>((ref) {
  _refetchOnAuthChange(ref);
  return ref.watch(progressServiceProvider).fetchCheckupHistory();
}, retry: _noRetry);

/// The 30 check-up questions, without answers. Only watched while a
/// check-up can be taken.
final checkupQuestionsProvider = FutureProvider<List<CheckupQuestion>>(
  (ref) => ref.watch(progressServiceProvider).fetchCheckupQuestions(),
  retry: _noRetry,
);

/// Reads `user_progress`, `checkup_history` and `checkup_questions`,
/// submits check-ups through the `submit_checkup` database function,
/// records section scores through `save_section_score` and quiz mistakes
/// through `upsert_mistakes`, completes lessons through `complete_lesson`
/// and reads statistics through `get_user_stats`.
///
/// Students can't write progress or history directly (RLS), and never see
/// `answer_index`; scoring, the level, the cooldown and lesson unlocks are
/// all decided on the server.
///
/// Notifies listeners after each successful write that changes the
/// statistics, so [userStatsProvider] refetches.
class ProgressService extends ChangeNotifier {
  ProgressService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<UserProgress> fetchProgress() async {
    final userId = _userId;
    if (userId == null) return const UserProgress();
    try {
      final row =
          await _supabase
              .from('user_progress')
              .select('current_lesson, cefr_level, last_checkup_date')
              .eq('user_id', userId)
              .maybeSingle();
      return UserProgress.fromJson(row);
    } catch (error, stackTrace) {
      _log('fetchProgress (user_progress)', error, stackTrace);
      rethrow;
    }
  }

  Future<UserStats> fetchStats() async {
    if (_userId == null) return const UserStats();
    try {
      final json = await _supabase.rpc<Map<String, dynamic>>('get_user_stats');
      return UserStats.fromJson(json);
    } catch (error, stackTrace) {
      _log('fetchStats', error, stackTrace);
      rethrow;
    }
  }

  Future<List<CheckupHistoryEntry>> fetchCheckupHistory() async {
    final userId = _userId;
    if (userId == null) return const [];
    try {
      final rows = await _supabase
          .from('checkup_history')
          .select('cefr_level, score, total, taken_at')
          .eq('user_id', userId)
          .order('taken_at', ascending: true);
      return [
        for (final row in rows)
          if (CheckupHistoryEntry.tryParse(row) case final entry?) entry,
      ];
    } catch (error, stackTrace) {
      _log('fetchCheckupHistory (checkup_history)', error, stackTrace);
      rethrow;
    }
  }

  Future<List<CheckupQuestion>> fetchCheckupQuestions() async {
    try {
      // Columns must be listed: students have no privilege on answer_index,
      // so `select *` is refused.
      final rows = await _supabase
          .from('checkup_questions')
          .select('id, level, question, options')
          .order('id', ascending: true);
      return [
        for (final row in rows)
          if (CheckupQuestion.tryParse(row) case final question?) question,
      ];
    } catch (error, stackTrace) {
      _log('fetchCheckupQuestions (checkup_questions)', error, stackTrace);
      rethrow;
    }
  }

  /// [answers] maps each question id to the chosen option index.
  ///
  /// Throws [CheckupCooldownException] when the server says the last
  /// check-up was under 10 days ago.
  Future<CheckupResult> submitCheckup(Map<int, int> answers) async {
    try {
      final result = await _supabase.rpc<Map<String, dynamic>>(
        'submit_checkup',
        params: {
          'p_answers': {
            for (final entry in answers.entries) '${entry.key}': entry.value,
          },
        },
      );
      return CheckupResult.fromJson(result);
    } on PostgrestException catch (error, stackTrace) {
      _log('submitCheckup', error, stackTrace);
      if (error.message == 'checkup_cooldown') {
        throw CheckupCooldownException(
          nextAllowed: DateTime.tryParse(error.hint ?? ''),
        );
      }
      rethrow;
    } catch (error, stackTrace) {
      _log('submitCheckup', error, stackTrace);
      rethrow;
    }
  }

  /// Stores the student's latest [score] (0–100) for one [section] of
  /// [lessonNumber]: one of [lessonSections].
  Future<void> saveSectionScore(
    int lessonNumber,
    String section,
    int score,
  ) async {
    try {
      await _supabase.rpc<Object?>(
        'save_section_score',
        params: {
          'p_lesson_number': lessonNumber,
          'p_section': section,
          'p_score': score,
        },
      );
    } catch (error, stackTrace) {
      _log('saveSectionScore', error, stackTrace);
      rethrow;
    }
    notifyListeners();
  }

  /// Records a graded [section] quiz ('reading' or 'listening') of
  /// [lessonNumber]: the 0-based [wrongQuestionIndexes] are tracked as
  /// mistakes (or counted again), and the section's other tracked
  /// mistakes are resolved.
  Future<void> saveMistakes(
    int lessonNumber,
    String section,
    List<int> wrongQuestionIndexes,
  ) async {
    try {
      await _supabase.rpc<Object?>(
        'upsert_mistakes',
        params: {
          'p_lesson_number': lessonNumber,
          'p_section': section,
          'p_wrong_indexes': wrongQuestionIndexes,
        },
      );
    } catch (error, stackTrace) {
      _log('saveMistakes', error, stackTrace);
      rethrow;
    }
    notifyListeners();
  }

  /// Unlocks the lesson after [lessonNumber] if it is the student's current
  /// lesson; completing an earlier lesson again changes nothing.
  ///
  /// Throws [InsufficientScoreException] when the lesson's section average
  /// is below [InsufficientScoreException.minAverage].
  ///
  /// Callers must invalidate [userProgressProvider] afterwards.
  Future<void> completeLesson(int lessonNumber) async {
    try {
      await _supabase.rpc<Object?>(
        'complete_lesson',
        params: {'completed_lesson': lessonNumber},
      );
    } on PostgrestException catch (error, stackTrace) {
      _log('completeLesson', error, stackTrace);
      if (error.message == 'insufficient_score') {
        throw InsufficientScoreException(average: _parseAverage(error.details));
      }
      rethrow;
    } catch (error, stackTrace) {
      _log('completeLesson', error, stackTrace);
      rethrow;
    }
    notifyListeners();
  }
}

/// The `p_section` values `save_section_score` accepts.
const lessonSections = [
  'grammar',
  'reading',
  'listening',
  'writing',
  'speaking',
];

/// Reads the average out of `complete_lesson`'s 'Score: 65' detail.
int? _parseAverage(Object? details) {
  final match = RegExp(r'Score:\s*(\d+)').firstMatch('${details ?? ''}');
  return match == null ? null : int.parse(match.group(1)!);
}

/// The server refused to unlock the next lesson because the section
/// average is below [minAverage].
class InsufficientScoreException implements Exception {
  const InsufficientScoreException({this.average});

  static const minAverage = 80;

  /// Rounded down; null if the server's detail couldn't be read.
  final int? average;

  @override
  String toString() => 'InsufficientScoreException(average: $average)';
}

/// The server rejected a submission because the cooldown hasn't passed.
class CheckupCooldownException implements Exception {
  const CheckupCooldownException({this.nextAllowed});

  final DateTime? nextAllowed;

  @override
  String toString() => 'CheckupCooldownException(next: $nextAllowed)';
}

/// User-facing Uzbek message for a failed check-up load or submission.
///
/// Debug builds append the Postgres/PostgREST code and message, so a
/// permission or schema problem is visible on screen, not only in the log.
String checkupErrorMessage(Object error) {
  final message = _userMessage(error);
  if (kDebugMode && error is PostgrestException) {
    return '$message\n\n[debug] ${error.code ?? 'no code'}: ${error.message}';
  }
  return message;
}

/// User-facing Uzbek message for a failed [ProgressService.completeLesson].
String lessonCompletionErrorMessage(Object error) {
  if (error is InsufficientScoreException) {
    const min = InsufficientScoreException.minAverage;
    final current =
        error.average == null ? '' : ' (hozirgi: ${error.average}%)';
    return "O'rtacha ballingiz $min% dan past$current. "
        "Keyingi darsga o'tish uchun bo'limlarni yaxshilang.";
  }
  final message =
      isNetworkError(error)
          ? "Internet aloqasi yo'q. Tarmoqni tekshirib, qayta urinib ko'ring."
          : "Darsni yakunlab bo'lmadi. Iltimos, qayta urinib ko'ring.";
  if (kDebugMode && error is PostgrestException) {
    return '$message\n\n[debug] ${error.code ?? 'no code'}: ${error.message}';
  }
  return message;
}

String _userMessage(Object error) {
  if (isNetworkError(error)) {
    return "Internet aloqasi yo'q. Tarmoqni tekshirib, qayta urinib ko'ring.";
  }
  if (error is CheckupCooldownException) {
    return "Keyingi daraja tekshiruvi hali ochilmagan.";
  }
  if (error is PostgrestException && error.message == 'invalid_answers') {
    return "Barcha savollarga javob berib, qayta yuboring.";
  }
  return "Nimadir xato ketdi. Iltimos, qayta urinib ko'ring.";
}

/// Prints every field of a [PostgrestException] on its own line; the
/// code tells the causes apart (42501 missing grant or RLS, 42P01 or
/// PGRST205 missing table or stale schema cache, 42703 missing column).
void _log(String action, Object error, StackTrace stackTrace) {
  if (!kDebugMode) return;
  if (error is PostgrestException) {
    debugPrint(
      '[Progress] $action failed with PostgrestException\n'
      '  message: ${error.message}\n'
      '  code:    ${error.code}\n'
      '  details: ${error.details}\n'
      '  hint:    ${error.hint}',
    );
  } else {
    debugPrint('[Progress] $action failed: ${error.runtimeType}: $error');
  }
  debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
}
