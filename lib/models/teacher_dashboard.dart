import 'user_progress.dart';

/// The teacher panel data from the `get_teacher_dashboard` database
/// function.
///
/// Parsing never throws: missing or malformed values read as 0, empty or
/// "no level", so one odd row can't blank the whole panel.
class TeacherDashboard {
  const TeacherDashboard({
    this.totalStudents = 0,
    this.totalGroups = 0,
    this.averageMastery = 0,
    this.groups = const [],
  });

  factory TeacherDashboard.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const {};
    return TeacherDashboard(
      totalStudents: _parseInt(data['total_students']).clamp(0, 1 << 31),
      totalGroups: _parseInt(data['total_groups']).clamp(0, 1 << 31),
      averageMastery: _parseInt(data['average_mastery']).clamp(0, 100),
      groups: [
        for (final group in _maps(data['groups'])) ClassGroup.fromJson(group),
      ],
    );
  }

  /// Distinct students across all groups; one in two groups counts once.
  final int totalStudents;
  final int totalGroups;

  /// Mean of the students' [TeacherStudent.masteryPercent], rounded down.
  final int averageMastery;

  /// Oldest first.
  final List<ClassGroup> groups;
}

/// A class the teacher created; students join with [login] and [password].
class ClassGroup {
  const ClassGroup({
    required this.id,
    required this.name,
    required this.login,
    required this.password,
    this.students = const [],
  });

  factory ClassGroup.fromJson(Map<String, dynamic> json) => ClassGroup(
    id: _parseString(json['id']) ?? '',
    name: _parseString(json['name']) ?? 'Group',
    login: _parseString(json['login_code']) ?? '',
    password: _parseString(json['password']) ?? '',
    students: [
      for (final student in _maps(json['students']))
        TeacherStudent.fromJson(student),
    ],
  );

  final String id;
  final String name;
  final String login;
  final String password;

  /// In joining order.
  final List<TeacherStudent> students;
}

/// A student connected to one of the teacher's groups.
class TeacherStudent {
  const TeacherStudent({
    required this.id,
    required this.fullName,
    this.username,
    this.currentLesson = UserProgress.firstLesson,
    this.masteryPercent = 0,
    this.cefrLevel,
  });

  factory TeacherStudent.fromJson(Map<String, dynamic> json) => TeacherStudent(
    id: _parseString(json['id']) ?? '',
    fullName: _parseString(json['full_name']) ?? 'Talaba',
    username: _parseString(json['username']),
    currentLesson: _parseInt(
      json['current_lesson'],
      fallback: UserProgress.firstLesson,
    ).clamp(UserProgress.firstLesson, UserProgress.lastLesson),
    masteryPercent: _parseInt(json['mastery']).clamp(0, 100),
    cefrLevel: _parseLevel(json['cefr_level']),
  );

  /// The student's user id, for `get_student_detail`.
  final String id;
  final String fullName;

  /// Without the leading `@`; null if the student has none.
  final String? username;
  final int currentLesson;

  /// Mean section average (0–100) of the completed lessons, rounded down.
  final int masteryPercent;

  /// One of [UserProgress.cefrLevels], or null before the first check-up.
  final String? cefrLevel;
}

/// Section scores for one of a student's lessons, each 0 – 100, from the
/// `get_student_detail` database function.
class LessonSkillProgress {
  const LessonSkillProgress({
    required this.lessonNumber,
    required this.title,
    this.isCurrent = false,
    this.grammar = 0,
    this.reading = 0,
    this.listening = 0,
    this.writing = 0,
    this.speaking = 0,
  });

  /// Null when [json] has no usable lesson number.
  static LessonSkillProgress? tryParse(Map<String, dynamic> json) {
    final number = _parseInt(json['lesson_number']);
    if (number < UserProgress.firstLesson || number > UserProgress.lastLesson) {
      return null;
    }
    int score(String key) => _parseInt(json[key]).clamp(0, 100);
    return LessonSkillProgress(
      lessonNumber: number,
      title: _parseString(json['title']) ?? 'Lesson $number',
      isCurrent: json['is_current'] == true,
      grammar: score('grammar'),
      reading: score('reading'),
      listening: score('listening'),
      writing: score('writing'),
      speaking: score('speaking'),
    );
  }

  final int lessonNumber;
  final String title;

  /// The lesson the student is working on now; the others are completed.
  final bool isCurrent;
  final int grammar;
  final int reading;
  final int listening;
  final int writing;
  final int speaking;

  List<(String, int)> get skills => [
    ('Grammar', grammar),
    ('Reading', reading),
    ('Listening', listening),
    ('Writing', writing),
    ('Speaking', speaking),
  ];
}

/// Result of `join_group`.
class JoinGroupResult {
  const JoinGroupResult({required this.groupName, this.alreadyMember = false});

  factory JoinGroupResult.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const {};
    return JoinGroupResult(
      groupName: _parseString(data['group_name']) ?? '',
      alreadyMember: data['already_member'] == true,
    );
  }

  final String groupName;

  /// The student was in the group before this call.
  final bool alreadyMember;
}

Iterable<Map<String, dynamic>> _maps(Object? value) =>
    value is List ? value.whereType<Map<String, dynamic>>() : const [];

int _parseInt(Object? value, {int fallback = 0}) => switch (value) {
  int v => v,
  num v when v.isFinite => v.floor(),
  String v => int.tryParse(v.trim()) ?? fallback,
  _ => fallback,
};

/// Blank strings count as missing.
String? _parseString(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

String? _parseLevel(Object? value) {
  final level = _parseString(value)?.toUpperCase();
  return UserProgress.cefrLevels.contains(level) ? level : null;
}
