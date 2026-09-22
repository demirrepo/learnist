/// Accuracy per skill for one completed lesson, each 0 – 100.
class LessonSkillProgress {
  const LessonSkillProgress({
    required this.lessonNumber,
    required this.title,
    this.grammar = 0,
    this.reading = 0,
    this.listening = 0,
    this.writing = 0,
    this.speaking = 0,
  });

  final int lessonNumber;
  final String title;
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

/// A student connected to one of the teacher's groups.
class TeacherStudent {
  const TeacherStudent({
    required this.fullName,
    required this.username,
    required this.currentLesson,
    required this.masteryPercent,
    required this.cefrLevel,
    this.topWeakness,
    this.recurringMistakes = const [],
    this.lessonProgress = const [],
  });

  final String fullName;

  /// Without the leading `@`.
  final String username;
  final int currentLesson;
  final int masteryPercent;
  final String cefrLevel;
  final String? topWeakness;
  final List<String> recurringMistakes;

  /// Completed lessons, most recent first.
  final List<LessonSkillProgress> lessonProgress;
}

/// A class the teacher created; students join with [login] and [password].
class ClassGroup {
  const ClassGroup({
    required this.name,
    required this.login,
    required this.password,
    required this.students,
  });

  final String name;
  final String login;
  final String password;
  final List<TeacherStudent> students;
}

// Placeholder content copied from the design mockups until groups come from
// the backend.
const sampleClassGroups = [
  ClassGroup(
    name: 'English group 301',
    login: 'ELT301',
    password: 'elt301',
    students: [
      TeacherStudent(
        fullName: 'Demirbek Razzaqov',
        username: 'redscorpnoir',
        currentLesson: 2,
        masteryPercent: 93,
        cefrLevel: 'C2',
        lessonProgress: [
          LessonSkillProgress(
            lessonNumber: 2,
            title: 'A world of sport',
            reading: 100,
          ),
          LessonSkillProgress(
            lessonNumber: 1,
            title: 'Hello, everybody!',
            grammar: 85,
          ),
        ],
      ),
    ],
  ),
];
