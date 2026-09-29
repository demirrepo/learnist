import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/models/checkup.dart';
import 'package:learnist/models/user_progress.dart';
import 'package:learnist/screens/checkup_screen.dart';
import 'package:learnist/services/progress_service.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../support/fake_progress_service.dart';

final _now = DateTime(2026, 9, 22, 12);

/// The progress providers only listen to the auth service for changes.
class _AuthStub extends ChangeNotifier implements SupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, FakeProgressService service) async {
  tester.view.physicalSize = const Size(600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(_AuthStub()),
        progressServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(home: CheckUpScreen(clock: () => _now)),
    ),
  );
  await tester.pumpAndSettle();
}

/// Picks option [option] in each of the first [count] questions.
Future<void> _answer(WidgetTester tester, {int? count, int option = 0}) async {
  final cards = find.byType(QuizQuestionCard).evaluate().toList();
  for (final card in cards.take(count ?? cards.length)) {
    final tile = find
        .descendant(
          of: find.byWidget(card.widget),
          matching: find.byType(InkWell),
        )
        .at(option);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
  }
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final submit = find.byKey(const ValueKey('checkup-submit'));
  // Centred, so an error snackbar at the bottom can't cover it.
  await Scrollable.ensureVisible(tester.element(submit), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _submitAndConfirm(WidgetTester tester) async {
  await _tapSubmit(tester);
  await tester.tap(find.byKey(const ValueKey('checkup-confirm-submit')));
  await tester.pumpAndSettle();
}

CheckupHistoryEntry _entry(String level, DateTime at) =>
    CheckupHistoryEntry(cefrLevel: level, score: 20, total: 30, takenAt: at);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('first time: all 30 questions and a submit button', (
    tester,
  ) async {
    await _pump(tester, FakeProgressService());

    expect(find.byType(QuizQuestionCard), findsNWidgets(30));
    expect(find.text('Submit check-up'), findsOneWidget);
    expect(find.text('0 / 30'), findsOneWidget);
    expect(find.text('Next level check in'), findsNothing);
    expect(find.text('CEFR growth'), findsNothing);
  });

  testWidgets('submitting with unanswered questions asks for all answers', (
    tester,
  ) async {
    final service = FakeProgressService();
    await _pump(tester, service);
    await _answer(tester, count: 29);
    expect(find.text('29 / 30'), findsOneWidget);

    await _tapSubmit(tester);

    expect(find.text('Barcha 30 ta savolga javob bering.'), findsOneWidget);
    expect(find.text('Natijani yuborasizmi?'), findsNothing);
    expect(service.lastSubmitted, isNull);
  });

  testWidgets('cancelling the confirmation sends nothing', (tester) async {
    final service = FakeProgressService();
    await _pump(tester, service);
    await _answer(tester);

    await _tapSubmit(tester);
    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();

    expect(service.lastSubmitted, isNull);
    expect(find.byType(QuizQuestionCard), findsNWidgets(30));
  });

  testWidgets('submit sends every answer, shows the level, then cooldown', (
    tester,
  ) async {
    final service = FakeProgressService(
      history: [_entry('A2', _now.subtract(const Duration(days: 40)))],
      nextResult: CheckupResult(
        cefrLevel: 'B1',
        score: 17,
        total: 30,
        takenAt: _now,
      ),
    );
    await _pump(tester, service);
    await _answer(tester, option: 1);
    await _submitAndConfirm(tester);

    expect(service.lastSubmitted, {
      for (final question in seedCheckupQuestions) question.id: 1,
    });
    expect(find.text('Your level: B1'), findsOneWidget);
    expect(find.textContaining('17/30 correct'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Refetched: the cooldown card and the chart with the new point.
    expect(find.byType(QuizQuestionCard), findsNothing);
    expect(find.text('10 days'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Retake unavailable'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Your last 2 checks'), findsOneWidget);
    expect(find.text('+1 level'), findsOneWidget);
    expect(find.text('B1 · 22 Sep'), findsOneWidget);
  });

  testWidgets('a server-side cooldown refreshes into the cooldown state', (
    tester,
  ) async {
    final service = FakeProgressService();
    await _pump(tester, service);
    await _answer(tester);

    // Another device submitted meanwhile.
    service
      ..submitError = const CheckupCooldownException()
      ..progress = UserProgress(
        cefrLevel: 'B2',
        lastCheckupDate: _now.subtract(const Duration(days: 1)),
      );
    await _submitAndConfirm(tester);

    expect(
      find.text('Keyingi daraja tekshiruvi hali ochilmagan.'),
      findsOneWidget,
    );
    expect(find.text('9 days'), findsOneWidget);
  });

  testWidgets('a failed submission keeps the answers for a retry', (
    tester,
  ) async {
    final service =
        FakeProgressService()
          ..submitError = const PostgrestException(message: 'boom');
    await _pump(tester, service);
    await _answer(tester);
    await _submitAndConfirm(tester);

    expect(find.textContaining('Nimadir xato ketdi'), findsOneWidget);
    expect(find.text('30 / 30'), findsOneWidget);

    service.submitError = null;
    await _submitAndConfirm(tester);
    expect(find.text('Your level: B1'), findsOneWidget);
  });

  testWidgets('cooldown: countdown and history chart, no questions fetched', (
    tester,
  ) async {
    final service = FakeProgressService(
      progress: UserProgress(
        cefrLevel: 'B2',
        lastCheckupDate: _now.subtract(const Duration(days: 3)),
      ),
      history: [
        _entry('A2', DateTime(2026, 8, 1)),
        _entry('B1', DateTime(2026, 8, 25)),
        _entry('B2', _now.subtract(const Duration(days: 3))),
      ],
    );
    await _pump(tester, service);

    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Submit check-up'), findsNothing);
    expect(find.text('Your last 3 checks'), findsOneWidget);
    expect(find.text('+2 levels'), findsOneWidget);
    expect(find.text('A2 · 1 Aug'), findsOneWidget);
    expect(service.questionFetches, 0);
  });

  testWidgets('the chart shows at most the last 6 checks', (tester) async {
    final service = FakeProgressService(
      progress: UserProgress(
        cefrLevel: 'C1',
        lastCheckupDate: _now.subtract(const Duration(days: 2)),
      ),
      history: [
        for (var i = 0; i < 8; i++)
          _entry(
            UserProgress.cefrLevels[i.clamp(0, 5)],
            DateTime(2026, 1 + i, 3),
          ),
      ],
    );
    await _pump(tester, service);

    expect(find.text('Your last 6 checks'), findsOneWidget);
    expect(find.text('A1 · 3 Jan'), findsNothing);
  });

  testWidgets('cooldown without history shows the empty chart state', (
    tester,
  ) async {
    await _pump(
      tester,
      FakeProgressService(
        progress: UserProgress(
          cefrLevel: 'A2',
          lastCheckupDate: _now.subtract(const Duration(days: 9, hours: 1)),
        ),
      ),
    );

    expect(find.text('1 day'), findsOneWidget);
    expect(
      find.text("Testni yechgach o'sish grafigi paydo bo'ladi"),
      findsOneWidget,
    );
  });

  testWidgets('an expired cooldown offers the test again', (tester) async {
    await _pump(
      tester,
      FakeProgressService(
        progress: UserProgress(
          cefrLevel: 'B1',
          lastCheckupDate: _now.subtract(const Duration(days: 11)),
        ),
      ),
    );

    expect(find.byType(QuizQuestionCard), findsNWidgets(30));
    expect(find.text('Retake unavailable'), findsNothing);
  });

  testWidgets('load failures show an Uzbek message and retry', (tester) async {
    final service = FakeProgressService()..progressError = Exception('down');
    await _pump(tester, service);

    expect(find.textContaining('Nimadir xato ketdi'), findsOneWidget);
    service.progressError = null;
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizQuestionCard), findsNWidgets(30));

    // Questions failing is retried on its own.
    final noQuestions =
        FakeProgressService()..questionsError = Exception('down');
    await _pump(tester, noQuestions);
    expect(find.text('Qayta urinish'), findsOneWidget);
    noQuestions.questionsError = null;
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizQuestionCard), findsNWidgets(30));
  });
}
