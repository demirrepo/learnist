import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/ask_ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An [AskAiService] on a real [SupabaseClient] whose HTTP calls go to
/// [handler], so functions_client's error handling is exercised too.
AskAiService _service(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient(handler),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  addTearDown(client.dispose);
  return AskAiService(client);
}

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

Matcher _failure(AskAiFailure failure, {int? statusCode}) => throwsA(
  isA<AskAiException>()
      .having((e) => e.failure, 'failure', failure)
      .having((e) => e.statusCode, 'statusCode', statusCode),
);

const _context = 'Lesson 49: Download the app | Grammar | Complex clauses';

void main() {
  test('posts the question and lesson context to ask-ai', () async {
    late http.Request sent;
    final service = _service((request) async {
      sent = request;
      return _json({'reply': ' **Hint 1:** look at the verb. '});
    });

    final answer = await service.ask('  Why is B wrong?  ', _context);

    expect(answer, '**Hint 1:** look at the verb.');
    expect(sent.method, 'POST');
    expect(sent.url.path, '/functions/v1/ask-ai');
    expect(jsonDecode(sent.body), {
      'prompt': 'Why is B wrong?',
      'lessonContext': _context,
    });
    // Signed out here, so the client falls back to the anon key; a signed-in
    // user's JWT goes in the same header.
    expect(sent.headers['Authorization'], 'Bearer anon-key');
  });

  test('a rate limit is reported as busy', () async {
    final service = _service(
      (_) async => _json({'error': 'rate_limited'}, 429),
    );
    await expectLater(
      service.ask('q', _context),
      _failure(AskAiFailure.busy, statusCode: 429),
    );
  });

  test('other error statuses are reported as failed', () async {
    final service = _service((_) async => _json({'error': 'upstream'}, 502));
    await expectLater(
      service.ask('q', _context),
      _failure(AskAiFailure.failed, statusCode: 502),
    );
  });

  test('a network failure is reported as offline', () async {
    final service = _service((_) async => throw http.ClientException('down'));
    await expectLater(
      service.ask('q', _context),
      _failure(AskAiFailure.offline),
    );
  });

  group('parseAskAiReply', () {
    test('reads reply', () {
      expect(parseAskAiReply({'reply': ' Two hints. '}), 'Two hints.');
    });

    test('rejects a missing, blank or differently named answer', () {
      for (final data in [
        null,
        'plain text',
        {'reply': '  '},
        {'reply': 42},
        {'content': 'a'},
        {'error': 'x'},
      ]) {
        expect(
          () => parseAskAiReply(data),
          throwsA(isA<AskAiException>()),
          reason: '$data',
        );
      }
    });
  });
}
