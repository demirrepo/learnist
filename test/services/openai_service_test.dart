import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/openai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An [OpenAIService] on a real [SupabaseClient] whose HTTP calls go to
/// [handler], so functions_client's error handling is exercised too.
OpenAIService _service(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient(handler),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  addTearDown(client.dispose);
  return OpenAIService(client);
}

/// An `evaluate_task` success whose model reply is [content].
http.Response _reply(String content) => http.Response.bytes(
  utf8.encode(jsonEncode({'content': content})),
  200,
  headers: {'content-type': 'application/json'},
);

http.Response _functionError(int status, String code) => http.Response(
  jsonEncode({'error': code}),
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

  group('parseFunctionReply', () {
    test('reads the content and trims it', () {
      expect(parseFunctionReply({'content': ' Zo\u2018r! '}), 'Zo\u2018r!');
    });

    test('rejects a missing or blank reply', () {
      for (final data in [
        null,
        '',
        'text',
        <String, Object>{},
        {'content': null},
        {'content': '  '},
        {'error': 'upstream_error'},
      ]) {
        expect(
          () => parseFunctionReply(data),
          _openAIError("AI bo'sh javob qaytardi. Qaytadan urinib ko'ring."),
          reason: '$data',
        );
      }
    });
  });

  group('OpenAIService', () {
    test('grades through evaluate_task without any OpenAI key', () async {
      late http.Request sent;
      final ai = _service((request) async {
        sent = request;
        return _reply('{"score": 88, "feedback": "Ajoyib."}');
      });

      expect(await ai.evaluateSpeaking(' I like tea. ', ' Your drink '), (
        score: 88,
        feedback: 'Ajoyib.',
      ));
      expect(sent.method, 'POST');
      expect(
        sent.url.toString(),
        'https://example.supabase.co/functions/v1/evaluate_task',
      );
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      // Only the anon key or the user's session; never an OpenAI key.
      expect(sent.headers['Authorization'], isNot(contains('sk-')));
      expect(jsonDecode(sent.body), {
        'kind': 'speaking',
        'text': 'I like tea.',
        'context': 'Your drink',
      });
    });

    test('each check sends its kind', () async {
      final kinds = <Object?>[];
      final ai = _service((request) async {
        kinds.add((jsonDecode(request.body) as Map)['kind']);
        return _reply('{"score": 70, "feedback": "Yaxshi."}');
      });

      await ai.evaluateGrammar('I am here.', 'to be');
      await ai.evaluateWriting('My city is big.', 'Your city');
      expect(kinds, ['grammar', 'writing']);
    });

    test('checks prompts as free text, decoding UTF-8', () async {
      late Map<String, dynamic> body;
      final ai = _service((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return _reply('**Rol** yo\u2018q.');
      });

      expect(await ai.evaluatePrompt(' Write a poem '), '**Rol** yo\u2018q.');
      expect(body, {'kind': 'prompt', 'text': 'Write a poem'});
    });

    test('a malformed grading reply is rejected', () async {
      final ai = _service((_) async => _reply('{"score": 90}'));
      await expectLater(
        ai.evaluateGrammar('I am here.', 'to be'),
        _openAIError("AI javobini o'qib bo'lmadi. Qaytadan urinib ko'ring."),
      );
    });

    test('error statuses keep their code; 429 says the AI is busy', () async {
      for (final (status, code, message) in [
        (
          429,
          'rate_limited',
          "AI hozir band. Birozdan so'ng qaytadan urinib ko'ring.",
        ),
        (401, 'unauthorized', "AI javob bera olmadi. Qaytadan urinib ko'ring."),
        (
          502,
          'upstream_error',
          "AI javob bera olmadi. Qaytadan urinib ko'ring.",
        ),
      ]) {
        final ai = _service((_) async => _functionError(status, code));
        await expectLater(
          ai.evaluateWriting('My city is big.', 'Your city'),
          _openAIError(message, statusCode: status),
          reason: '$status',
        );
      }
    });

    test('a network failure says there is no internet', () async {
      final ai = _service((_) async => throw http.ClientException('offline'));
      await expectLater(
        ai.evaluatePrompt('Hi'),
        _openAIError("Internetga ulanib bo'lmadi. Qaytadan urinib ko'ring."),
      );
    });

    test('checks the answer before calling the function', () async {
      var calls = 0;
      final ai = _service((_) async {
        calls++;
        return _reply('{}');
      });

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
      expect(calls, 0);
    });
  });
}
