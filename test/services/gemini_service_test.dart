import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/services/gemini_service.dart';

void main() {
  group('parseEvaluation', () {
    test('reads the score and feedback', () {
      expect(parseEvaluation('{"score": 85, "feedback": " Juda yaxshi. "}'), (
        score: 85,
        feedback: 'Juda yaxshi.',
      ));
    });

    test('tolerates a markdown code fence', () {
      expect(
        parseEvaluation('```json\n{"score": 70, "feedback": "Yaxshi."}\n```'),
        (score: 70, feedback: 'Yaxshi.'),
      );
    });

    test('rounds fractional scores and clamps to 0–100', () {
      expect(parseEvaluation('{"score": 79.6, "feedback": "a"}').score, 80);
      expect(parseEvaluation('{"score": 140, "feedback": "a"}').score, 100);
      expect(parseEvaluation('{"score": -5, "feedback": "a"}').score, 0);
    });

    test('rejects anything else', () {
      for (final reply in [
        'Score: 85',
        '[]',
        '{"score": "85", "feedback": "a"}',
        '{"score": 85}',
        '{"feedback": "a"}',
        '{"score": 85, "feedback": "  "}',
      ]) {
        expect(
          () => parseEvaluation(reply),
          throwsA(isA<GeminiException>()),
          reason: reply,
        );
      }
    });
  });

  test('every grader asks for an answer before calling Gemini', () {
    final gemini = GeminiService();
    for (final grade in [
      () => gemini.evaluateGrammar('   ', 'Present Simple'),
      () => gemini.evaluateWriting('', 'Describe your city.'),
      () => gemini.evaluateSpeaking('\n', 'Talk about your hobby.'),
    ]) {
      expect(
        grade(),
        throwsA(
          isA<GeminiException>().having(
            (e) => e.message,
            'message',
            'Avval javobingizni yozing.',
          ),
        ),
      );
    }
  });
}
