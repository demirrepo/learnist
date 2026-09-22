import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/models/lesson_model.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/theme/app_theme.dart';
import 'package:learnist/services/lesson_service.dart';
import 'package:learnist/widgets/lesson/lesson_common.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../support/fake_lesson_service.dart';

Future<void> _pump(
  WidgetTester tester, {
  int lessonId = 1,
  FakeLessonService? service,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lessonServiceProvider.overrideWithValue(service ?? FakeLessonService()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: LessonDetailScreen(lessonId: lessonId),
      ),
    ),
  );
  settle ? await tester.pumpAndSettle() : await tester.pump();
}

/// Tall enough that each tab's lazy list builds every card.
void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Picks the first option of every question in the visible quiz.
Future<void> _answerFirstOptions(WidgetTester tester) async {
  final cards = find.descendant(
    of: find.byType(LessonQuiz),
    matching: find.byType(LessonCard),
  );
  for (final card in cards.evaluate().toList()) {
    await tester.tap(
      find
          .descendant(
            of: find.byWidget(card.widget),
            matching: find.byType(InkWell),
          )
          .first,
    );
  }
  await tester.pump();
}

int _firstOptionScore(List<dynamic> raw) =>
    QuizQuestion.listFrom(
      raw,
    ).where((question) => question.correctIndex == 0).length;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final lesson1 = seedLessons.first;

  testWidgets('shows a spinner, then the lesson title and CEFR level', (
    tester,
  ) async {
    final service = FakeLessonService(pending: Completer<void>());
    await _pump(tester, lessonId: 7, service: service, settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Lesson 7'), findsOneWidget);

    service.pending!.complete();
    await tester.pumpAndSettle();

    final lesson7 = seedLessons[6];
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Lesson 7: ${lesson7.title}'), findsOneWidget);
    expect(find.text(lesson7.cefrLevel), findsOneWidget);
  });

  testWidgets('an error shows an Uzbek message and retry reloads', (
    tester,
  ) async {
    final service = FakeLessonService(
      error: const PostgrestException(message: 'boom'),
    );
    await _pump(tester, service: service);

    expect(find.textContaining("Darslarni yuklab bo'lmadi"), findsOneWidget);
    expect(find.byType(TabBarView), findsNothing);

    service.error = null;
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();

    expect(service.fetchCount, 2);
    expect(find.text('Lesson 1: ${lesson1.title}'), findsOneWidget);
  });

  testWidgets('an unknown lesson says it was not found', (tester) async {
    await _pump(tester, lessonId: 99);
    expect(find.text('Dars topilmadi.'), findsOneWidget);
  });

  testWidgets('grammar tab shows the rule and focus', (tester) async {
    _useTallView(tester);
    await _pump(tester);

    expect(find.text(lesson1.grammarFocus), findsOneWidget);
    expect(find.text(lesson1.grammarRules!), findsOneWidget);
    expect(find.text('Umumiy qoida'), findsNothing);
  });

  testWidgets('lesson 38 marks its general grammar guide', (tester) async {
    await _pump(tester, lessonId: 38);
    expect(find.text('Umumiy qoida'), findsOneWidget);
  });

  testWidgets('reading tab: passage, live quiz with aggregate score, vocab', (
    tester,
  ) async {
    _useTallView(tester);
    await _pump(tester);
    await _openTab(tester, "O'qish");

    expect(find.text(lesson1.readingPassage!), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LessonQuiz),
        matching: find.byType(LessonCard),
      ),
      findsNWidgets(10),
    );
    expect(find.text('6 key words'), findsOneWidget);

    await _answerFirstOptions(tester);
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    final score = _firstOptionScore(lesson1.readingQuestions);
    expect(find.text('$score/10 correct'), findsOneWidget);
  });

  testWidgets('listening tab: format, blurred transcript, live quiz', (
    tester,
  ) async {
    _useTallView(tester);
    await _pump(tester);
    await _openTab(tester, 'Tinglab tushunish');

    expect(find.text('Two-speaker conversation'), findsOneWidget);
    final firstLine = lesson1.listeningTranscript!.split('\n').first;
    // Present but blurred (and hidden from screen readers) until revealed.
    expect(find.textContaining(firstLine), findsOneWidget);
    expect(find.byType(ImageFiltered), findsOneWidget);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.byType(ImageFiltered), findsNothing);

    await _answerFirstOptions(tester);
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    final score = _firstOptionScore(lesson1.listeningQuestions);
    expect(find.text('$score/10 correct'), findsOneWidget);
  });

  testWidgets('writing and speaking tabs show the live prompts', (
    tester,
  ) async {
    _useTallView(tester);
    await _pump(tester);

    await _openTab(tester, 'Yozish');
    expect(find.text(lesson1.writingPrompt!), findsOneWidget);

    await _openTab(tester, 'Gapirish');
    expect(find.text(lesson1.speakingPrompt!), findsOneWidget);
  });

  testWidgets('missing sections show their Uzbek notices', (tester) async {
    _useTallView(tester);
    const bare = Lesson(
      lessonNumber: 1,
      originalNumber: 1,
      semester: 1,
      title: 'Bare lesson',
      grammarFocus: 'Nothing yet',
      cefrLevel: 'A1',
    );
    await _pump(tester, service: FakeLessonService(lessons: const [bare]));

    expect(
      find.text("Ushbu darsda grammatika qoidalari yo'q."),
      findsOneWidget,
    );

    await _openTab(tester, "O'qish");
    expect(find.text("Ushbu darsda o'qish mashqi yo'q."), findsOneWidget);
    expect(find.byType(LessonQuiz), findsNothing);
    expect(find.text("Lug'at"), findsNothing);

    await _openTab(tester, 'Tinglab tushunish');
    expect(
      find.text("Ushbu darsda tinglab tushunish mashqi yo'q."),
      findsOneWidget,
    );

    await _openTab(tester, 'Yozish');
    expect(find.text("Ushbu darsda yozish mashqi yo'q."), findsOneWidget);

    await _openTab(tester, 'Gapirish');
    expect(find.text("Ushbu darsda gapirish mashqi yo'q."), findsOneWidget);
  });
}
