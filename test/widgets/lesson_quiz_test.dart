import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/theme/app_theme.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';

const _questions = [
  QuizQuestion(prompt: 'Q one', options: ['a1', 'b1'], correctIndex: 0),
  QuizQuestion(prompt: 'Q two', options: ['a2', 'b2'], correctIndex: 0),
];

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('asks for all answers before scoring', (tester) async {
    await tester.pumpWidget(_host(const LessonQuiz(questions: _questions)));
    await tester.tap(find.text('a1'));
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    expect(find.text('Answer all 2 questions to check your results.'),
        findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows only the aggregate score', (tester) async {
    await tester.pumpWidget(_host(const LessonQuiz(questions: _questions)));
    await tester.tap(find.text('a1'));
    await tester.tap(find.text('b2'));
    await tester.pumpAndSettle();

    final before = tester.allWidgets.whereType<AnimatedContainer>()
        .map((w) => w.decoration)
        .toList();

    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    expect(find.text('1/2 correct'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Option styling is unchanged after checking — nothing reveals answers.
    final after = tester.allWidgets.whereType<AnimatedContainer>()
        .map((w) => w.decoration)
        .toList();
    expect(after, before);
  });

  testWidgets('lesson screen fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LessonDetailScreen()),
    );
    final controller =
        DefaultTabController.of(tester.element(find.byType(TabBarView)));
    for (var i = 1; i < 5; i++) {
      controller.animateTo(i);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tab $i');
    }
    expect(tester.takeException(), isNull);
  });
}
