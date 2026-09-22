import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkup.dart';
import '../models/user_progress.dart';
import 'supabase_service.dart' show isNetworkError, supabaseServiceProvider;

final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(),
);

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

/// Reads `user_progress`, `checkup_history` and `checkup_questions`, and
/// submits check-ups through the `submit_checkup` database function.
///
/// Students can't write progress or history directly (RLS), and never see
/// `answer_index`; scoring, the level and the cooldown are all decided on
/// the server.
class ProgressService {
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
