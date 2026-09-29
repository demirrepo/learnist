import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/services/lesson_service.dart';
import 'package:learnist/theme/app_theme.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';

import '../support/fake_lesson_service.dart';
import '../support/l10n.dart';

const _questions = [
  QuizQuestion(prompt: 'Q one', options: ['a1', 'b1'], correctIndex: 0),
  QuizQuestion(prompt: 'Q two', options: ['a2', 'b2'], correctIndex: 0),
];

Widget _host(Widget child) => MaterialApp(
  locale: testLocale,
  localizationsDelegates: testLocalizationsDelegates,
  supportedLocales: testSupportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('asks for all answers before scoring', (tester) async {
    await tester.pumpWidget(_host(const LessonQuiz(questions: _questions)));
    await tester.tap(find.text('a1'));
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    expect(
      find.text('Answer all 2 questions to check your results.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('reports the percentage and wrong answers once all are '
      'answered', (tester) async {
    final scores = <int>[];
    final wrongs = <List<int>>[];
    await tester.pumpWidget(
      _host(
        LessonQuiz(
          questions: _questions,
          onScored: (score, wrong) {
            scores.add(score);
            wrongs.add(wrong);
          },
        ),
      ),
    );

    await tester.tap(find.text('a1'));
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();
    expect(scores, isEmpty);

    await tester.tap(find.text('b2'));
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('a2'));
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();
    expect(scores, [50, 100]);
    expect(wrongs, [
      [1],
      <int>[],
    ]);
  });

  testWidgets('shows only the aggregate score', (tester) async {
    await tester.pumpWidget(_host(const LessonQuiz(questions: _questions)));
    await tester.tap(find.text('a1'));
    await tester.tap(find.text('b2'));
    await tester.pumpAndSettle();

    final before =
        tester.allWidgets
            .whereType<AnimatedContainer>()
            .map((w) => w.decoration)
            .toList();

    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    expect(find.text('1/2 correct'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Option styling is unchanged after checking — nothing reveals answers.
    final after =
        tester.allWidgets
            .whereType<AnimatedContainer>()
            .map((w) => w.decoration)
            .toList();
    expect(after, before);
  });

  // Lesson 38 uses the fallback grammar guide; 52 is the longest C1 lesson.
  for (final lessonId in [1, 38, 52]) {
    testWidgets('lesson $lessonId fits a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonServiceProvider.overrideWithValue(FakeLessonService()),
          ],
          child: MaterialApp(
            locale: testLocale,
            localizationsDelegates: testLocalizationsDelegates,
            supportedLocales: testSupportedLocales,

            theme: AppTheme.light,
            home: LessonDetailScreen(lessonId: lessonId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final controller = DefaultTabController.of(
        tester.element(find.byType(TabBarView)),
      );
      for (var i = 1; i < 5; i++) {
        controller.animateTo(i);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tab $i');
      }
      expect(tester.takeException(), isNull);
    });
  }

  group('QuizQuestion.tryParse', () {
    test('reads a seeded question', () {
      final question = QuizQuestion.tryParse({
        'question': ' Where? ',
        'options': ['a', 'b', 'c'],
        'answer_index': 2,
        'hint': 'ignored',
      });
      expect(question?.prompt, 'Where?');
      expect(question?.options, ['a', 'b', 'c']);
      expect(question?.correctIndex, 2);
    });

    test('accepts a whole-number double index', () {
      final question = QuizQuestion.tryParse({
        'question': 'Q',
        'options': ['a', 'b'],
        'answer_index': 1.0,
      });
      expect(question?.correctIndex, 1);
    });

    test('rejects items that cannot be scored reliably', () {
      const bad = <Object?>[
        null,
        'not a map',
        {
          'options': ['a', 'b'],
          'answer_index': 0,
        },
        {
          'question': ' ',
          'options': ['a', 'b'],
          'answer_index': 0,
        },
        {
          'question': 'Q',
          'options': ['a'],
          'answer_index': 0,
        },
        {'question': 'Q', 'options': 'a,b', 'answer_index': 0},
        // Dropping the bad option would shift the answer index.
        {
          'question': 'Q',
          'options': ['a', 3, 'c'],
          'answer_index': 2,
        },
        {
          'question': 'Q',
          'options': ['a', 'b'],
          'answer_index': 2,
        },
        {
          'question': 'Q',
          'options': ['a', 'b'],
          'answer_index': -1,
        },
        {
          'question': 'Q',
          'options': ['a', 'b'],
          'answer_index': '1',
        },
        {
          'question': 'Q',
          'options': ['a', 'b'],
          'answer_index': 0.5,
        },
      ];
      for (final raw in bad) {
        expect(QuizQuestion.tryParse(raw), isNull, reason: '$raw');
      }
    });

    test('listFrom keeps valid items and skips the rest', () {
      final questions = QuizQuestion.listFrom([
        {
          'question': 'Q1',
          'options': ['a', 'b'],
          'answer_index': 0,
        },
        {'question': 'broken'},
        {
          'question': 'Q2',
          'options': ['a', 'b'],
          'answer_index': 1,
        },
      ]);
      expect(questions.map((q) => q.prompt), ['Q1', 'Q2']);
    });

    test('every seeded question parses', () {
      for (final lesson in seedLessons) {
        expect(
          QuizQuestion.listFrom(lesson.readingQuestions),
          hasLength(lesson.readingQuestions.length),
        );
        expect(
          QuizQuestion.listFrom(lesson.listeningQuestions),
          hasLength(lesson.listeningQuestions.length),
        );
      }
    });
  });
}
