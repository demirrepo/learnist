import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/openai_service.dart';

/// A Chat Completions response whose reply is [content].
http.Response _completion(String content, {int status = 200}) => http.Response(
  jsonEncode({
    'choices': [
      {
        'index': 0,
        'message': {'role': 'assistant', 'content': content},
        'finish_reason': 'stop',
      },
    ],
  }),
  status,
  headers: {'content-type': 'application/json'},
);

Matcher _openAIError(String message, {int? statusCode}) => throwsA(
  isA<OpenAIException>()
      .having((e) => e.message, 'message', message)
      .having((e) => e.statusCode, 'statusCode', statusCode),
);

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
          throwsA(isA<OpenAIException>()),
          reason: reply,
        );
      }
    });
  });

  group('parseCompletion', () {
    test('reads the first choice and trims it', () {
      expect(parseCompletion(_completion(' Zo\u2018r! ').body), 'Zo\u2018r!');
    });

    test('rejects a missing or blank reply', () {
      for (final body in [
        'not json',
        '{}',
        '{"choices": []}',
        '{"choices": [{"message": {"content": null, "refusal": "No."}}]}',
        '{"choices": [{"message": {"content": "  "}}]}',
      ]) {
        expect(
          () => parseCompletion(body),
          _openAIError("AI bo'sh javob qaytardi. Qaytadan urinib ko'ring."),
          reason: body,
        );
      }
    });
  });

  group('OpenAIService', () {
    test('grades with gpt-4o-mini in JSON mode', () async {
      late http.Request sent;
      final ai = OpenAIService(
        apiKey: 'sk-test',
        client: MockClient((request) async {
          sent = request;
          return _completion('{"score": 88, "feedback": "Ajoyib."}');
        }),
      );

      expect(await ai.evaluateSpeaking(' I like tea. ', 'Your drink'), (
        score: 88,
        feedback: 'Ajoyib.',
      ));
      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'https://api.openai.com/v1/chat/completions');
      expect(sent.headers['Authorization'], 'Bearer sk-test');
      expect(sent.headers['Content-Type'], startsWith('application/json'));

      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['model'], 'gpt-4o-mini');
      expect(body['response_format'], {'type': 'json_object'});
      final messages = body['messages'] as List;
      expect(messages, hasLength(2));
      expect(messages[0]['role'], 'system');
      // JSON mode is rejected unless the instructions mention JSON.
      expect(messages[0]['content'], contains('JSON'));
      expect(messages[1], {
        'role': 'user',
        'content':
            'Speaking task: Your drink\n\nStudent text:\n"""\nI like tea.\n"""',
      });
    });

    test('checks prompts as free text, decoding UTF-8', () async {
      late Map<String, dynamic> body;
      final ai = OpenAIService(
        apiKey: 'sk-test',
        client: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, dynamic>;
          // No charset: package:http alone would read this as Latin-1.
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'choices': [
                  {
                    'message': {'content': '**Rol** yo\u2018q.'},
                  },
                ],
              }),
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(await ai.evaluatePrompt('Write a poem'), '**Rol** yo\u2018q.');
      expect(body.containsKey('response_format'), isFalse);
      expect(body['messages'][1], {'role': 'user', 'content': 'Write a poem'});
    });

    test('a malformed grading reply is rejected', () async {
      final ai = OpenAIService(
        apiKey: 'sk-test',
        client: MockClient((_) async => _completion('{"score": 90}')),
      );
      await expectLater(
        ai.evaluateGrammar('I am here.', 'to be'),
        _openAIError("AI javobini o'qib bo'lmadi. Qaytadan urinib ko'ring."),
      );
    });

    test('error statuses keep their code; 429 says the AI is busy', () async {
      for (final (status, message) in [
        (429, "AI hozir band. Birozdan so'ng qaytadan urinib ko'ring."),
        (401, "AI javob bera olmadi. Qaytadan urinib ko'ring."),
        (503, "AI javob bera olmadi. Qaytadan urinib ko'ring."),
      ]) {
        final ai = OpenAIService(
          apiKey: 'sk-test',
          client: MockClient(
            (_) async => http.Response('{"error": {"message": "x"}}', status),
          ),
        );
        await expectLater(
          ai.evaluateWriting('My city is big.', 'Your city'),
          _openAIError(message, statusCode: status),
          reason: '$status',
        );
      }
    });

    test('a network failure says there is no internet', () async {
      final ai = OpenAIService(
        apiKey: 'sk-test',
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      await expectLater(
        ai.evaluatePrompt('Hi'),
        _openAIError("Internetga ulanib bo'lmadi. Qaytadan urinib ko'ring."),
      );
    });

    test('checks the answer and the key before calling OpenAI', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return _completion('{}');
      });
      final ai = OpenAIService(apiKey: 'sk-test', client: client);

      for (final grade in [
        () => ai.evaluateGrammar('   ', 'Present Simple'),
        () => ai.evaluateWriting('', 'Describe your city.'),
        () => ai.evaluateSpeaking('\n', 'Talk about your hobby.'),
      ]) {
        await expectLater(grade(), _openAIError('Avval javobingizni yozing.'));
      }
      await expectLater(
        ai.evaluatePrompt(' '),
        _openAIError('Avval promptingizni yozing.'),
      );
      await expectLater(
        OpenAIService(apiKey: '', client: client).evaluatePrompt('Hi'),
        _openAIError('OPENAI_API_KEY topilmadi. .env faylini tekshiring.'),
      );
      expect(calls, 0);
    });
  });
}
