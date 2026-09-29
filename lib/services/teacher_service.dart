import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/teacher_dashboard.dart';
import 'progress_service.dart' show noRetry, refetchOnAuthChange;
import 'supabase_service.dart' show isNetworkError;

final teacherServiceProvider = Provider<TeacherService>(
  (ref) => TeacherService(),
);

/// The teacher panel's groups, students and statistics.
///
/// Callers invalidate it after creating a group.
final teacherDashboardProvider = FutureProvider<TeacherDashboard>((ref) {
  refetchOnAuthChange(ref);
  return ref.watch(teacherServiceProvider).fetchDashboard();
}, retry: noRetry);

/// One student's lessons, most recent first, for the student detail
/// dialog. Refetched every time the dialog opens.
final studentLessonsProvider = FutureProvider.autoDispose
    .family<List<LessonSkillProgress>, String>(
      (ref, studentId) =>
          ref.watch(teacherServiceProvider).fetchStudentLessons(studentId),
      retry: noRetry,
    );

/// Class groups: creating them and reading their students' progress
/// (teachers), and joining one with its class login and password
/// (students).
///
/// Reads go through the `get_teacher_dashboard` and `get_student_detail`
/// database functions, joining through `join_group`. RLS limits a teacher
/// to their own groups and the students in them; students never read
/// `student_groups`.
class TeacherService {
  TeacherService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Allowed characters in a class login, after [normalizeLogin].
  static final loginPattern = RegExp(r'^[A-Z0-9_-]{3,32}$');

  /// Logins are stored upper-case, so students can type them in any case.
  static String normalizeLogin(String login) => login.trim().toUpperCase();

  Future<TeacherDashboard> fetchDashboard() async {
    if (_supabase.auth.currentUser == null) return const TeacherDashboard();
    try {
      final json = await _supabase.rpc<Map<String, dynamic>>(
        'get_teacher_dashboard',
      );
      return TeacherDashboard.fromJson(json);
    } catch (error, stackTrace) {
      _log('fetchDashboard', error, stackTrace);
      rethrow;
    }
  }

  /// Lessons from the student's current one back to lesson 1.
  Future<List<LessonSkillProgress>> fetchStudentLessons(
    String studentId,
  ) async {
    try {
      final rows = await _supabase.rpc<List<dynamic>>(
        'get_student_detail',
        params: {'p_student_id': studentId},
      );
      return [
        for (final row in rows.whereType<Map<String, dynamic>>())
          if (LessonSkillProgress.tryParse(row) case final lesson?) lesson,
      ];
    } catch (error, stackTrace) {
      _log('fetchStudentLessons', error, stackTrace);
      rethrow;
    }
  }

  /// Creates a group owned by the signed-in teacher.
  ///
  /// Throws [GroupLoginTakenException] when another group has [login].
  Future<void> createGroup({
    required String name,
    required String login,
    required String password,
  }) async {
    try {
      await _supabase.from('student_groups').insert({
        'name': name.trim(),
        'login_code': normalizeLogin(login),
        'password': password.trim(),
      });
    } on PostgrestException catch (error, stackTrace) {
      _log('createGroup', error, stackTrace);
      // unique_violation on login_code.
      if (error.code == '23505') throw const GroupLoginTakenException();
      rethrow;
    } catch (error, stackTrace) {
      _log('createGroup', error, stackTrace);
      rethrow;
    }
  }

  /// Adds the signed-in student to the group with [login] and [password].
  ///
  /// Throws [InvalidGroupCredentialsException] when no group matches, and
  /// [OwnGroupException] when the caller created the group.
  Future<JoinGroupResult> joinGroup({
    required String login,
    required String password,
  }) async {
    try {
      final json = await _supabase.rpc<Map<String, dynamic>>(
        'join_group',
        params: {
          'p_login_code': normalizeLogin(login),
          'p_password': password.trim(),
        },
      );
      return JoinGroupResult.fromJson(json);
    } on PostgrestException catch (error, stackTrace) {
      _log('joinGroup', error, stackTrace);
      switch (error.message) {
        case 'invalid_credentials':
          throw const InvalidGroupCredentialsException();
        case 'own_group':
          throw const OwnGroupException();
      }
      rethrow;
    } catch (error, stackTrace) {
      _log('joinGroup', error, stackTrace);
      rethrow;
    }
  }
}

/// No group has this class login and password.
class InvalidGroupCredentialsException implements Exception {
  const InvalidGroupCredentialsException();
}

/// A teacher tried to join a group they created.
class OwnGroupException implements Exception {
  const OwnGroupException();
}

/// Another group already uses the class login.
class GroupLoginTakenException implements Exception {
  const GroupLoginTakenException();
}

const _networkMessage =
    "Internet aloqasi yo'q. Tarmoqni tekshirib, qayta urinib ko'ring.";

/// User-facing Uzbek message for a successful [TeacherService.joinGroup].
String joinGroupSuccessMessage(JoinGroupResult result) =>
    result.alreadyMember
        ? "Siz allaqachon «${result.groupName}» guruhidasiz."
        : "«${result.groupName}» guruhiga qo'shildingiz.";

/// User-facing Uzbek message for a failed [TeacherService.joinGroup].
String joinGroupErrorMessage(Object error) => switch (error) {
  InvalidGroupCredentialsException() => "Login yoki parol noto'g'ri.",
  OwnGroupException() => "O'zingiz yaratgan guruhga qo'shila olmaysiz.",
  _ when isNetworkError(error) => _networkMessage,
  _ => "Guruhga qo'shilib bo'lmadi. Iltimos, qayta urinib ko'ring.",
};

/// User-facing Uzbek message for a failed [TeacherService.createGroup].
String createGroupErrorMessage(Object error) => switch (error) {
  GroupLoginTakenException() => "Bu login band. Iltimos, boshqa login tanlang.",
  _ when isNetworkError(error) => _networkMessage,
  _ => "Guruh yaratilmadi. Iltimos, qayta urinib ko'ring.",
};

/// User-facing Uzbek message for a failed dashboard or student load.
String teacherLoadErrorMessage(Object error) =>
    isNetworkError(error)
        ? _networkMessage
        : "Ma'lumotlarni yuklab bo'lmadi. Iltimos, qayta urinib ko'ring.";

void _log(String action, Object error, StackTrace stackTrace) {
  if (!kDebugMode) return;
  if (error is PostgrestException) {
    debugPrint(
      '[Teacher] $action failed with PostgrestException\n'
      '  message: ${error.message}\n'
      '  code:    ${error.code}\n'
      '  details: ${error.details}',
    );
  } else {
    debugPrint('[Teacher] $action failed: ${error.runtimeType}: $error');
  }
  debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
}
