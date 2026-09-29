import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/models/teacher_dashboard.dart';
import 'package:learnist/screens/teacher_panel_screen.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:learnist/services/teacher_service.dart';
import 'package:learnist/widgets/load_problem_view.dart';
import 'package:learnist/widgets/teacher/create_group_dialog.dart';
import 'package:learnist/widgets/teacher/student_detail_dialog.dart';

import '../support/fake_teacher_service.dart';
import '../support/l10n.dart';

/// The dashboard provider only listens to the auth service for changes.
class _AuthStub extends ChangeNotifier implements SupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _demirbek = TeacherStudent(
  id: 's1',
  fullName: 'Demirbek Razzaqov',
  username: 'redscorpnoir',
  currentLesson: 2,
  masteryPercent: 93,
  cefrLevel: 'C2',
);

const _aziza = TeacherStudent(
  id: 's2',
  fullName: 'Aziza Tursunova',
  currentLesson: 1,
  masteryPercent: 81,
);

const _dashboard = TeacherDashboard(
  totalStudents: 2,
  totalGroups: 1,
  averageMastery: 87,
  groups: [
    ClassGroup(
      id: 'g1',
      name: 'English group 301',
      login: 'ELT301',
      password: 'elt301',
      students: [_demirbek, _aziza],
    ),
  ],
);

final _demirbekLessons = [
  const LessonSkillProgress(
    lessonNumber: 2,
    title: 'A world of sport',
    isCurrent: true,
    reading: 100,
    listening: 40,
  ),
  const LessonSkillProgress(
    lessonNumber: 1,
    title: 'Hello, everybody!',
    grammar: 85,
    reading: 90,
    listening: 80,
    writing: 75,
    speaking: 70,
  ),
];

Future<void> _pump(
  WidgetTester tester,
  FakeTeacherService teacher, {
  Size size = const Size(600, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(_AuthStub()),
        teacherServiceProvider.overrideWithValue(teacher),
      ],
      child: const MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        home: TeacherPanelScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('dashboard', () {
    testWidgets('maps the stats, without a Common issues block', (
      tester,
    ) async {
      await _pump(tester, FakeTeacherService(dashboard: _dashboard));

      expect(find.bySemanticsLabel('Students active: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Average mastery: 87%'), findsOneWidget);
      expect(find.bySemanticsLabel('Groups: 1'), findsOneWidget);
      expect(find.bySemanticsLabel('2 connected students'), findsOneWidget);
      expect(find.text('1 group • 2 connected students'), findsOneWidget);
      expect(find.text('Common issues'), findsNothing);
      expect(find.text('Most common weaknesses'), findsNothing);
    });

    testWidgets('lists each group with its credentials and students', (
      tester,
    ) async {
      await _pump(tester, FakeTeacherService(dashboard: _dashboard));

      expect(find.text('English group 301'), findsOneWidget);
      expect(
        find.text('Class login: ELT301 • password: elt301', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('2 students'), findsOneWidget);
      expect(find.text('Demirbek Razzaqov'), findsOneWidget);
      expect(find.text('@redscorpnoir'), findsOneWidget);
      expect(find.text('Aziza Tursunova'), findsOneWidget);
      // Phone layout: one tile per student with the table's columns.
      Finder chip(String text) => find.text(text, findRichText: true);
      expect(chip('Lesson  L2'), findsOneWidget);
      expect(chip('Mastery  93%'), findsOneWidget);
      expect(chip('CEFR  C2'), findsOneWidget);
      // No check-up yet.
      expect(chip('CEFR  —'), findsOneWidget);
      expect(find.text('View'), findsNWidgets(2));
    });

    testWidgets('wide screens show the student table', (tester) async {
      await _pump(
        tester,
        FakeTeacherService(dashboard: _dashboard),
        size: const Size(1280, 1400),
      );

      expect(find.text('TALABA'), findsOneWidget);
      expect(find.text('CEFR'), findsOneWidget);
      expect(find.text('TOP WEAKNESS'), findsNothing);
      expect(find.bySemanticsLabel('Average mastery: 87%'), findsOneWidget);
    });

    testWidgets('no groups shows the empty state', (tester) async {
      await _pump(tester, FakeTeacherService());

      expect(
        find.text('No groups yet. Create one to connect students.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Students active: 0'), findsOneWidget);
      expect(find.bySemanticsLabel('Average mastery: 0%'), findsOneWidget);
    });

    testWidgets('a failed load shows an Uzbek message and retries', (
      tester,
    ) async {
      final teacher = FakeTeacherService(dashboard: _dashboard)
        ..dashboardError = Exception('down');
      await _pump(tester, teacher);

      expect(find.byType(LoadProblemView), findsOneWidget);
      expect(find.textContaining("Ma'lumotlarni yuklab"), findsOneWidget);

      teacher.dashboardError = null;
      await _tapVisible(tester, find.text('Qayta urinish'));

      expect(find.byType(LoadProblemView), findsNothing);
      expect(find.text('English group 301'), findsOneWidget);
      expect(teacher.dashboardFetches, 2);
    });
  });

  group('student detail', () {
    testWidgets('View fetches the student and maps each lesson\'s scores', (
      tester,
    ) async {
      final teacher = FakeTeacherService(
        dashboard: _dashboard,
        studentLessons: {'s1': _demirbekLessons},
      );
      await _pump(tester, teacher);

      await _tapVisible(tester, find.text('View').first);

      expect(teacher.lessonFetches, ['s1']);
      final dialog = find.byType(StudentDetailDialog);
      expect(dialog, findsOneWidget);
      Finder inDialog(Finder finder) =>
          find.descendant(of: dialog, matching: finder);
      expect(
        inDialog(find.text('@redscorpnoir • current Lesson 2')),
        findsOneWidget,
      );
      expect(
        inDialog(find.bySemanticsLabel('Average mastery: 93%')),
        findsOneWidget,
      );
      expect(inDialog(find.bySemanticsLabel('CEFR: C2')), findsOneWidget);
      expect(
        inDialog(find.text('A world of sport • in progress')),
        findsOneWidget,
      );
      expect(
        inDialog(
          find.text(
            'Grammar 0% • Reading 100% • Listening 40% • Writing 0% • '
            'Speaking 0%',
          ),
        ),
        findsOneWidget,
      );
      expect(inDialog(find.text('Hello, everybody!')), findsOneWidget);
      expect(
        inDialog(
          find.text(
            'Grammar 85% • Reading 90% • Listening 80% • Writing 75% • '
            'Speaking 70%',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Recurring mistakes'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('student-detail-close')));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);

      // Reopening fetches fresh scores.
      await _tapVisible(tester, find.text('View').first);
      expect(teacher.lessonFetches, ['s1', 's1']);
    });

    testWidgets('a student without a username or level', (tester) async {
      await _pump(tester, FakeTeacherService(dashboard: _dashboard));

      await _tapVisible(tester, find.text('View').last);

      expect(find.text('current Lesson 1'), findsOneWidget);
      expect(find.bySemanticsLabel('CEFR: —'), findsOneWidget);
      expect(find.text('No lessons started yet.'), findsOneWidget);
    });

    testWidgets('a failed fetch can be retried inside the dialog', (
      tester,
    ) async {
      final teacher = FakeTeacherService(
        dashboard: _dashboard,
        studentLessons: {'s1': _demirbekLessons},
      )..lessonsError = Exception('down');
      await _pump(tester, teacher);

      await _tapVisible(tester, find.text('View').first);
      expect(find.textContaining("Ma'lumotlarni yuklab"), findsOneWidget);

      teacher.lessonsError = null;
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, everybody!'), findsOneWidget);
      expect(teacher.lessonFetches, ['s1', 's1']);
    });
  });

  group('create group', () {
    Future<void> fillAndSubmit(
      WidgetTester tester, {
      String name = 'Evening class',
      String login = 'eve-1',
      String password = 'secret',
    }) async {
      await tester.enterText(
        find.byKey(const ValueKey('create-group-name')),
        name,
      );
      await tester.enterText(
        find.byKey(const ValueKey('create-group-login')),
        login,
      );
      await tester.enterText(
        find.byKey(const ValueKey('create-group-password')),
        password,
      );
      await tester.tap(find.byKey(const ValueKey('create-group-submit')));
      await tester.pumpAndSettle();
    }

    testWidgets('creates the group and refetches the dashboard', (
      tester,
    ) async {
      final teacher = FakeTeacherService();
      await _pump(tester, teacher);

      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teacher-create-group')),
      );
      expect(find.byType(CreateGroupDialog), findsOneWidget);
      await fillAndSubmit(tester);

      expect(teacher.createdGroups.single.login, 'EVE-1');
      expect(find.byType(CreateGroupDialog), findsNothing);
      expect(find.text('«Evening class» guruhi yaratildi.'), findsOneWidget);
      expect(teacher.dashboardFetches, 2);
      expect(find.text('Evening class'), findsOneWidget);
      expect(find.text('No students connected yet.'), findsOneWidget);
    });

    testWidgets('invalid fields are caught before any request', (tester) async {
      final teacher = FakeTeacherService();
      await _pump(tester, teacher);

      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teacher-create-group')),
      );
      await fillAndSubmit(tester, name: ' ', login: 'a b', password: '123');

      expect(find.text('Guruh nomini kiriting.'), findsOneWidget);
      expect(
        find.text("Login 3–32 ta harf, raqam, _ yoki - bo'lsin."),
        findsOneWidget,
      );
      expect(
        find.text("Parol 4–64 ta belgidan iborat bo'lsin."),
        findsOneWidget,
      );
      expect(teacher.createdGroups, isEmpty);
    });

    testWidgets('a taken login keeps the dialog open with the reason', (
      tester,
    ) async {
      final teacher =
          FakeTeacherService()..createError = const GroupLoginTakenException();
      await _pump(tester, teacher);

      await _tapVisible(
        tester,
        find.byKey(const ValueKey('teacher-create-group')),
      );
      await fillAndSubmit(tester);

      expect(find.byType(CreateGroupDialog), findsOneWidget);
      expect(
        find.text('Bu login band. Iltimos, boshqa login tanlang.'),
        findsOneWidget,
      );
      expect(teacher.dashboardFetches, 1);
    });
  });
}
