import 'package:learnist/models/teacher_dashboard.dart';
import 'package:learnist/services/teacher_service.dart';

/// In-memory stand-in for `student_groups`, `join_group`,
/// `get_teacher_dashboard` and `get_student_detail`.
///
/// [createGroup] adds an empty group to [dashboard], so a refetch after
/// creating shows it. [joinGroup] accepts only [joinableGroups].
class FakeTeacherService implements TeacherService {
  FakeTeacherService({
    this.dashboard = const TeacherDashboard(),
    Map<String, List<LessonSkillProgress>>? studentLessons,
    Map<(String, String), String>? joinableGroups,
  }) : studentLessons = {...?studentLessons},
       joinableGroups = {...?joinableGroups};

  TeacherDashboard dashboard;

  /// Lessons per student id; unknown ids have none.
  final Map<String, List<LessonSkillProgress>> studentLessons;

  /// Group names by (normalized login, password).
  final Map<(String, String), String> joinableGroups;

  Object? dashboardError;
  Object? lessonsError;
  Object? createError;
  Object? joinError;

  int dashboardFetches = 0;
  final List<String> lessonFetches = [];
  final List<({String name, String login, String password})> createdGroups = [];
  final Set<(String, String)> _joined = {};

  @override
  Future<TeacherDashboard> fetchDashboard() async {
    dashboardFetches++;
    if (dashboardError case final error?) throw error;
    return dashboard;
  }

  @override
  Future<List<LessonSkillProgress>> fetchStudentLessons(
    String studentId,
  ) async {
    lessonFetches.add(studentId);
    if (lessonsError case final error?) throw error;
    return studentLessons[studentId] ?? const [];
  }

  @override
  Future<void> createGroup({
    required String name,
    required String login,
    required String password,
  }) async {
    if (createError case final error?) throw error;
    final normalized = TeacherService.normalizeLogin(login);
    createdGroups.add((name: name, login: normalized, password: password));
    dashboard = TeacherDashboard(
      totalStudents: dashboard.totalStudents,
      totalGroups: dashboard.totalGroups + 1,
      averageMastery: dashboard.averageMastery,
      groups: [
        ...dashboard.groups,
        ClassGroup(
          id: 'group-${createdGroups.length}',
          name: name.trim(),
          login: normalized,
          password: password.trim(),
        ),
      ],
    );
  }

  @override
  Future<JoinGroupResult> joinGroup({
    required String login,
    required String password,
  }) async {
    if (joinError case final error?) throw error;
    final key = (TeacherService.normalizeLogin(login), password.trim());
    final name = joinableGroups[key];
    if (name == null) throw const InvalidGroupCredentialsException();
    return JoinGroupResult(groupName: name, alreadyMember: !_joined.add(key));
  }
}
