import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/models/lesson_model.dart';
import 'package:learnist/models/user_progress.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/theme/app_theme.dart';
import 'package:learnist/services/deepgram_service.dart';
import 'package:learnist/services/lesson_service.dart';
import 'package:learnist/services/openai_service.dart';
import 'package:learnist/services/progress_service.dart';
import 'package:learnist/services/speech_recorder.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:learnist/widgets/lesson/lesson_common.dart';
import 'package:learnist/widgets/lesson/lesson_quiz.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../support/fake_deepgram_service.dart';
import '../support/fake_lesson_service.dart';
import '../support/fake_openai_service.dart';
import '../support/fake_progress_service.dart';
import '../support/fake_speech_recorder.dart';

/// The progress providers only listen to the auth service for changes.
class _AuthStub extends ChangeNotifier implements SupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(
  WidgetTester tester, {
  int lessonId = 1,
  FakeLessonService? service,
  FakeProgressService? progress,
  FakeOpenAIService? ai,
  FakeDeepgramService? deepgram,
  FakeSpeechRecorder? recorder,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(_AuthStub()),
        lessonServiceProvider.overrideWithValue(service ?? FakeLessonService()),
        progressServiceProvider.overrideWithValue(
          progress ?? FakeProgressService(),
        ),
        openaiServiceProvider.overrideWithValue(ai ?? FakeOpenAIService()),
        deepgramServiceProvider.overrideWithValue(
          deepgram ?? FakeDeepgramService(),
        ),
        speechRecorderProvider.overrideWithValue(
          recorder ?? FakeSpeechRecorder(),
        ),
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

/// Indexes of the questions whose answer isn't the first option.
List<int> _wrongWithFirstOptions(List<dynamic> raw) {
  final questions = QuizQuestion.listFrom(raw);
  return [
    for (var i = 0; i < questions.length; i++)
      if (questions[i].correctIndex != 0) i,
  ];
}

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

  group('Analyze my answer', () {
    final answer = find.byKey(const ValueKey('grammar-answer'));
    final analyze = find.ancestor(
      of: find.text('Analyze my answer'),
      matching: find.bySubtype<FilledButton>(),
    );
    final result = find.byKey(const ValueKey('grammar-result'));
    const text = 'I play football every day. She reads books.';

    testWidgets('scores the answer, saves it and shows the feedback', (
      tester,
    ) async {
      _useTallView(tester);
      final ai =
          FakeOpenAIService()
            ..pending = Completer<void>()
            ..result = (score: 85, feedback: 'Zamon to\'g\'ri.');
      final progress = FakeProgressService();
      await _pump(tester, ai: ai, progress: progress);

      await tester.enterText(answer, text);
      await tester.tap(analyze);
      await tester.pump();

      // Loading: spinner, button disabled, nothing saved yet.
      expect(
        find.descendant(
          of: analyze,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(tester.widget<ButtonStyleButton>(analyze).onPressed, isNull);
      expect(progress.sectionScores, isEmpty);

      ai.pending!.complete();
      await tester.pumpAndSettle();

      expect(ai.calls.single, (
        section: 'grammar',
        studentText: text,
        topic: lesson1.grammarFocus,
      ));
      expect(progress.sectionScores, {
        1: {'grammar': 85},
      });
      expect(find.text('Mastery reached: 85%'), findsOneWidget);
      expect(find.text('Zamon to\'g\'ri.'), findsOneWidget);
      expect(tester.widget<ButtonStyleButton>(analyze).onPressed, isNotNull);
    });

    testWidgets('keeps the answer and result across tab switches', (
      tester,
    ) async {
      _useTallView(tester);
      await _pump(tester);

      await tester.enterText(answer, text);
      await tester.tap(analyze);
      await tester.pumpAndSettle();
      expect(result, findsOneWidget);

      await _openTab(tester, 'Gapirish');
      expect(result, findsNothing);
      await _openTab(tester, 'Grammatika');

      expect(find.text('Mastery reached: 85%'), findsOneWidget);
      expect(find.text(text), findsOneWidget);
    });

    testWidgets('a failed evaluation shows a red Uzbek snackbar', (
      tester,
    ) async {
      _useTallView(tester);
      final ai =
          FakeOpenAIService()..error = const OpenAIException('Internet yo\'q');
      final progress = FakeProgressService();
      await _pump(tester, ai: ai, progress: progress);

      await tester.enterText(answer, text);
      await tester.tap(analyze);
      await tester.pumpAndSettle();

      const message =
          "Baholashda xatolik yuz berdi. Iltimos qayta urinib ko'ring.";
      expect(find.text(message), findsOneWidget);
      expect(
        tester
            .widget<SnackBar>(
              find.ancestor(
                of: find.text(message),
                matching: find.byType(SnackBar),
              ),
            )
            .backgroundColor,
        AppColors.danger,
      );
      expect(progress.sectionScores, isEmpty);
      expect(result, findsNothing);
      expect(tester.widget<ButtonStyleButton>(analyze).onPressed, isNotNull);
    });

    testWidgets('an empty answer is not sent', (tester) async {
      _useTallView(tester);
      final ai = FakeOpenAIService();
      await _pump(tester, ai: ai);

      await tester.enterText(answer, '   ');
      await tester.tap(analyze);
      await tester.pumpAndSettle();

      expect(ai.calls, isEmpty);
      expect(find.text('Avval javobingizni yozing.'), findsOneWidget);
    });

    testWidgets('a failed save still shows the score and says so', (
      tester,
    ) async {
      _useTallView(tester);
      final progress =
          FakeProgressService()..saveScoreError = ClientException('offline');
      await _pump(tester, progress: progress);

      await tester.enterText(answer, text);
      await tester.tap(analyze);
      await tester.pumpAndSettle();

      expect(find.text('Mastery reached: 85%'), findsOneWidget);
      expect(
        find.text("Ball saqlanmadi. Iltimos qayta urinib ko'ring."),
        findsOneWidget,
      );
    });
  });

  group('Writing and speaking are graded like grammar', () {
    for (final task in [
      (
        tab: 'Yozish',
        section: 'writing',
        button: 'Assess my writing',
        topic: lesson1.writingPrompt!,
      ),
      (
        tab: 'Gapirish',
        section: 'speaking',
        button: 'Assess speaking',
        topic: lesson1.speakingPrompt!,
      ),
    ]) {
      testWidgets('${task.section}: grades, saves and shows the score', (
        tester,
      ) async {
        _useTallView(tester);
        final ai =
            FakeOpenAIService()..result = (score: 72, feedback: 'Yaxshi.');
        final progress = FakeProgressService();
        await _pump(tester, ai: ai, progress: progress);
        await _openTab(tester, task.tab);

        const text = 'I usually spend my weekends with my family.';
        await tester.enterText(
          find.byKey(ValueKey('${task.section}-answer')),
          text,
        );
        await tester.tap(find.text(task.button));
        await tester.pumpAndSettle();

        expect(ai.calls.single, (
          section: task.section,
          studentText: text,
          topic: task.topic,
        ));
        expect(progress.sectionScores, {
          1: {task.section: 72},
        });
        expect(find.text('Mastery reached: 72%'), findsOneWidget);
        expect(find.text('Yaxshi.'), findsOneWidget);
      });
    }

    testWidgets('writing counts words as the student types', (tester) async {
      _useTallView(tester);
      await _pump(tester);
      await _openTab(tester, 'Yozish');

      expect(find.text('0 / 80–120 words'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('writing-answer')),
        'One two  three',
      );
      await tester.pump();
      expect(find.text('3 / 80–120 words'), findsOneWidget);
    });

    testWidgets('speaking keeps "Darsni yakunlash" below the assessment', (
      tester,
    ) async {
      _useTallView(tester);
      await _pump(tester);
      await _openTab(tester, 'Gapirish');

      final assess = tester.getTopLeft(find.text('Assess speaking'));
      final complete = tester.getTopLeft(find.text('Darsni yakunlash'));
      expect(complete.dy, greaterThan(assess.dy));
    });
  });

  group('Speaking by microphone', () {
    final mic = find.byKey(const ValueKey('speaking-mic'));
    final answer = find.byKey(const ValueKey('speaking-answer'));
    final assess = find.ancestor(
      of: find.text('Assess speaking'),
      matching: find.bySubtype<FilledButton>(),
    );

    String answerText(WidgetTester tester) =>
        tester
            .widget<TextField>(
              find.descendant(of: answer, matching: find.byType(TextField)),
            )
            .controller!
            .text;

    Color? snackBarColor(WidgetTester tester, String message) =>
        tester
            .widget<SnackBar>(
              find.ancestor(
                of: find.text(message),
                matching: find.byType(SnackBar),
              ),
            )
            .backgroundColor;

    Future<void> openSpeaking(
      WidgetTester tester, {
      FakeOpenAIService? ai,
      FakeDeepgramService? deepgram,
      FakeSpeechRecorder? recorder,
    }) async {
      _useTallView(tester);
      await _pump(tester, ai: ai, deepgram: deepgram, recorder: recorder);
      await _openTab(tester, 'Gapirish');
    }

    testWidgets('only the speaking task has a microphone', (tester) async {
      _useTallView(tester);
      await _pump(tester);
      expect(find.byKey(const ValueKey('grammar-mic')), findsNothing);

      await _openTab(tester, 'Yozish');
      expect(find.byKey(const ValueKey('writing-mic')), findsNothing);

      await _openTab(tester, 'Gapirish');
      expect(mic, findsOneWidget);
      expect(find.byTooltip('Start recording'), findsOneWidget);
    });

    testWidgets('records, transcribes into the field, then grades it', (
      tester,
    ) async {
      final recorder = FakeSpeechRecorder();
      final deepgram = FakeDeepgramService(
        transcript: 'I usually cook on Sundays.',
      )..pending = Completer<void>();
      final ai = FakeOpenAIService();
      await openSpeaking(
        tester,
        ai: ai,
        deepgram: deepgram,
        recorder: recorder,
      );

      await tester.tap(find.byTooltip('Start recording'));
      // The pulse repeats while recording, so pump rather than settle.
      await tester.pump();
      expect(recorder.recording, isTrue);
      expect(find.text('Recording… Tap to stop'), findsOneWidget);
      expect(tester.widget<ButtonStyleButton>(assess).onPressed, isNull);

      await tester.tap(find.byTooltip('Stop recording'));
      await tester.pump();
      expect(recorder.recording, isFalse);
      expect(find.text('Transcribing…'), findsOneWidget);
      expect(
        find.descendant(
          of: mic,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(deepgram.paths, ['/tmp/speaking.m4a']);

      deepgram.pending!.complete();
      await tester.pumpAndSettle();

      expect(answerText(tester), 'I usually cook on Sundays.');
      expect(recorder.deleted, ['/tmp/speaking.m4a']);
      expect(find.byTooltip('Start recording'), findsOneWidget);
      expect(ai.calls, isEmpty);

      await tester.tap(assess);
      await tester.pumpAndSettle();
      expect(ai.calls.single.studentText, 'I usually cook on Sundays.');
      expect(find.text('Mastery reached: 85%'), findsOneWidget);
    });

    for (final denial in [
      (
        permission: MicPermission.denied,
        message: 'Ovoz yozish uchun mikrofonga ruxsat bering.',
      ),
      (
        permission: MicPermission.permanentlyDenied,
        message:
            'Mikrofonga ruxsat berilmagan. Uni telefon sozlamalaridan yoqing.',
      ),
    ]) {
      testWidgets('${denial.permission.name} microphone shows a red snackbar', (
        tester,
      ) async {
        final recorder = FakeSpeechRecorder(permission: denial.permission);
        await openSpeaking(tester, recorder: recorder);

        await tester.tap(find.byTooltip('Start recording'));
        await tester.pumpAndSettle();

        expect(recorder.recording, isFalse);
        expect(snackBarColor(tester, denial.message), AppColors.danger);
        expect(find.byTooltip('Start recording'), findsOneWidget);
      });
    }

    testWidgets('a recorder failure shows a red snackbar', (tester) async {
      final recorder =
          FakeSpeechRecorder()..startError = Exception('mic in use');
      await openSpeaking(tester, recorder: recorder);

      await tester.tap(find.byTooltip('Start recording'));
      await tester.pumpAndSettle();

      expect(
        snackBarColor(
          tester,
          "Ovoz yozishni boshlab bo'lmadi. Iltimos qayta urinib ko'ring.",
        ),
        AppColors.danger,
      );
    });

    testWidgets('a failed transcription keeps the typed answer', (
      tester,
    ) async {
      final recorder = FakeSpeechRecorder();
      final deepgram =
          FakeDeepgramService()
            ..error = const DeepgramException(
              "Internet aloqasi yo'q. Iltimos qayta urinib ko'ring.",
            );
      await openSpeaking(tester, deepgram: deepgram, recorder: recorder);
      await tester.enterText(answer, 'My typed answer.');

      await tester.tap(find.byTooltip('Start recording'));
      await tester.pump();
      await tester.tap(find.byTooltip('Stop recording'));
      await tester.pumpAndSettle();

      expect(
        snackBarColor(
          tester,
          "Internet aloqasi yo'q. Iltimos qayta urinib ko'ring.",
        ),
        AppColors.danger,
      );
      expect(answerText(tester), 'My typed answer.');
      expect(recorder.deleted, ['/tmp/speaking.m4a']);
      expect(tester.widget<ButtonStyleButton>(assess).onPressed, isNotNull);
    });

    testWidgets('leaving the lesson while recording stops the recorder', (
      tester,
    ) async {
      final recorder = FakeSpeechRecorder();
      await openSpeaking(tester, recorder: recorder);

      await tester.tap(find.byTooltip('Start recording'));
      await tester.pump();
      expect(recorder.recording, isTrue);

      await tester.pumpWidget(const SizedBox());
      expect(recorder.cancelCount, 1);
      expect(recorder.recording, isFalse);
    });
  });

  testWidgets('reading tab: passage, live quiz with aggregate score, vocab', (
    tester,
  ) async {
    _useTallView(tester);
    final progress = FakeProgressService();
    await _pump(tester, progress: progress);
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
    expect(progress.sectionScores, {
      1: {'reading': score * 10},
    });
    final mistakes = progress.mistakeCalls.single;
    expect((mistakes.lesson, mistakes.section), (1, 'reading'));
    expect(mistakes.wrong, _wrongWithFirstOptions(lesson1.readingQuestions));
  });

  testWidgets('a quiz score that fails to save shows a red snackbar', (
    tester,
  ) async {
    _useTallView(tester);
    final progress =
        FakeProgressService()..saveScoreError = ClientException('offline');
    await _pump(tester, progress: progress);
    await _openTab(tester, "O'qish");

    await _answerFirstOptions(tester);
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    const message = "Ball saqlanmadi. Iltimos qayta urinib ko'ring.";
    expect(find.text(message), findsOneWidget);
    expect(
      tester
          .widget<SnackBar>(
            find.ancestor(
              of: find.text(message),
              matching: find.byType(SnackBar),
            ),
          )
          .backgroundColor,
      AppColors.danger,
    );
    // The score dialog still shows.
    final score = _firstOptionScore(lesson1.readingQuestions);
    expect(find.text('$score/10 correct'), findsOneWidget);
  });

  testWidgets('a failed mistake update only logs; the score still saves', (
    tester,
  ) async {
    _useTallView(tester);
    final progress =
        FakeProgressService()..saveMistakesError = ClientException('offline');
    await _pump(tester, progress: progress);
    await _openTab(tester, "O'qish");

    await _answerFirstOptions(tester);
    await tester.tap(find.text('Natijani tekshirish'));
    await tester.pumpAndSettle();

    final score = _firstOptionScore(lesson1.readingQuestions);
    expect(progress.sectionScores, {
      1: {'reading': score * 10},
    });
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('$score/10 correct'), findsOneWidget);
  });

  testWidgets('listening tab: format, blurred transcript, live quiz', (
    tester,
  ) async {
    _useTallView(tester);
    final progress = FakeProgressService();
    await _pump(tester, progress: progress);
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
    expect(progress.sectionScores, {
      1: {'listening': score * 10},
    });
    final mistakes = progress.mistakeCalls.single;
    expect((mistakes.lesson, mistakes.section), (1, 'listening'));
    expect(mistakes.wrong, _wrongWithFirstOptions(lesson1.listeningQuestions));
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

  group('Darsni yakunlash', () {
    final complete = find.byKey(const ValueKey('complete-lesson'));

    testWidgets('ends the speaking tab of the current lesson', (tester) async {
      _useTallView(tester);
      await _pump(tester);

      expect(complete, findsNothing);
      await _openTab(tester, 'Gapirish');
      expect(find.text('Darsni yakunlash'), findsOneWidget);
    });

    testWidgets('is hidden when reviewing an earlier lesson', (tester) async {
      _useTallView(tester);
      await _pump(
        tester,
        progress: FakeProgressService(
          progress: const UserProgress(currentLesson: 3),
        ),
      );
      await _openTab(tester, 'Gapirish');
      expect(complete, findsNothing);
    });

    testWidgets('is hidden on the last lesson', (tester) async {
      _useTallView(tester);
      await _pump(
        tester,
        lessonId: UserProgress.lastLesson,
        progress: FakeProgressService(
          progress: const UserProgress(currentLesson: UserProgress.lastLesson),
        ),
      );
      await _openTab(tester, 'Gapirish');
      expect(complete, findsNothing);
    });

    testWidgets('a network failure shows an Uzbek message and stays', (
      tester,
    ) async {
      _useTallView(tester);
      final progress =
          FakeProgressService()..completeError = ClientException('offline');
      await _pump(tester, progress: progress);
      await _openTab(tester, 'Gapirish');

      await tester.tap(complete);
      await tester.pumpAndSettle();

      expect(progress.completedLessons, [1]);
      expect(find.textContaining("Internet aloqasi yo'q"), findsOneWidget);
      expect(find.byType(LessonDetailScreen), findsOneWidget);
      // Re-enabled for another try.
      expect(tester.widget<ButtonStyleButton>(complete).onPressed, isNotNull);
    });

    testWidgets('an average under 80% shows the score in a red snackbar', (
      tester,
    ) async {
      _useTallView(tester);
      final progress =
          FakeProgressService()
            ..completeError = const InsufficientScoreException(average: 65);
      await _pump(tester, progress: progress);
      await _openTab(tester, 'Gapirish');

      await tester.tap(complete);
      await tester.pumpAndSettle();

      expect(progress.completedLessons, [1]);
      expect(progress.progress.currentLesson, 1);
      expect(
        find.text(
          "O'rtacha ballingiz 80% dan past (hozirgi: 65%). "
          "Keyingi darsga o'tish uchun bo'limlarni yaxshilang.",
        ),
        findsOneWidget,
      );
      final snackBar = tester.widget<SnackBar>(
        find.byKey(const ValueKey('complete-lesson-error')),
      );
      expect(snackBar.backgroundColor, AppColors.danger);
      expect(find.byType(LessonDetailScreen), findsOneWidget);
      expect(tester.widget<ButtonStyleButton>(complete).onPressed, isNotNull);
    });
  });
}
