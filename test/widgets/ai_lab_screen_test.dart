import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/screens/ai_lab_screen.dart';
import 'package:learnist/services/openai_service.dart';
import 'package:learnist/widgets/ai_lab/ai_course_list.dart';

import '../support/fake_openai_service.dart';

/// The AI Lab with [ai] answering the prompt checker.
Widget _aiLab(FakeOpenAIService ai) => ProviderScope(
  overrides: [openaiServiceProvider.overrideWithValue(ai)],
  child: const MaterialApp(home: AiLabScreen()),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lays out on a narrow phone with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.3),
        ),
        child: ProviderScope(child: MaterialApp(home: AiLabScreen())),
      ),
    );

    expect(find.text('PROMPT LITERACY'), findsOneWidget);
    for (final part in ['Role', 'Task', 'Level', 'Context', 'Format']) {
      expect(find.text(part), findsWidgets);
    }

    await tester.scrollUntilVisible(
      find.text('Examples & Tone'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(AiCourseStepCard), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'prompt checker has an input, a check button and no feedback yet',
    (tester) async {
      await tester.pumpWidget(_aiLab(FakeOpenAIService()));

      expect(find.text('Prompt checker'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Write a prompt...'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Check my prompt'),
        findsOneWidget,
      );
      expect(find.byType(MarkdownBody), findsNothing);
      expect(find.text('AI fikri'), findsNothing);
    },
  );

  testWidgets('checking an empty prompt asks for one first', (tester) async {
    final ai =
        FakeOpenAIService()
          ..error = const OpenAIException('Avval promptingizni yozing.');
    await tester.pumpWidget(_aiLab(ai));

    await tester.enterText(find.byType(TextField), '   ');
    await tester.ensureVisible(find.text('Check my prompt'));
    await tester.tap(find.text('Check my prompt'));
    await tester.pump();

    expect(find.text('Avval promptingizni yozing.'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Check my prompt'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a checked prompt shows the AI feedback as Markdown', (
    tester,
  ) async {
    final ai = FakeOpenAIService(promptFeedback: '**Role** is missing.');
    await tester.pumpWidget(_aiLab(ai));

    await tester.enterText(find.byType(TextField), 'Write a poem');
    await tester.ensureVisible(find.text('Check my prompt'));
    await tester.tap(find.text('Check my prompt'));
    await tester.pumpAndSettle();

    expect(ai.prompts, ['Write a poem']);
    expect(find.text('AI fikri'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(
      find.textContaining('is missing.', findRichText: true),
      findsOneWidget,
    );
  });
}
