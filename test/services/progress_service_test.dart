import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [ProgressService] on a real [SupabaseClient] whose HTTP calls go to
/// [handler], so PostgREST's error decoding is exercised too.
({ProgressService service, List<http.Request> requests}) _service(
  Future<http.Response> Function(http.Request request) handler,
) {
  final requests = <http.Request>[];
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient((request) async {
      requests.add(request);
      // postgrest reads the method back from the response's request.
      final response = await handler(request);
      return http.Response(
        response.body,
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    }),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  addTearDown(client.dispose);
  return (service: ProgressService(client), requests: requests);
}

http.Response _postgrestError(Map<String, Object?> body) => http.Response(
  jsonEncode(body),
  400,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('saveSectionScore', () {
    test('calls save_section_score with the section and score', () async {
      final (:service, :requests) = _service(
        (_) async => http.Response('', 204),
      );

      await service.saveSectionScore(3, 'reading', 90);

      expect(requests.single.url.path, '/rest/v1/rpc/save_section_score');
      expect(jsonDecode(requests.single.body), {
        'p_lesson_number': 3,
        'p_section': 'reading',
        'p_score': 90,
      });
    });

    test('rethrows server errors', () async {
      final (:service, requests: _) = _service(
        (_) async =>
            _postgrestError({'code': '22023', 'message': 'invalid_section'}),
      );

      expect(
        service.saveSectionScore(3, 'vocabulary', 90),
        throwsA(
          isA<PostgrestException>().having(
            (e) => e.message,
            'message',
            'invalid_section',
          ),
        ),
      );
    });
  });

  group('completeLesson', () {
    test('calls complete_lesson with the lesson number', () async {
      final (:service, :requests) = _service(
        (_) async => http.Response('4', 200),
      );

      await service.completeLesson(3);

      expect(requests.single.url.path, '/rest/v1/rpc/complete_lesson');
      expect(jsonDecode(requests.single.body), {'completed_lesson': 3});
    });

    test('turns insufficient_score into InsufficientScoreException', () async {
      final (:service, requests: _) = _service(
        (_) async => _postgrestError({
          'code': 'P0001',
          'message': 'insufficient_score',
          'details': 'Score: 65',
          'hint': null,
        }),
      );

      expect(
        service.completeLesson(3),
        throwsA(
          isA<InsufficientScoreException>().having(
            (e) => e.average,
            'average',
            65,
          ),
        ),
      );
    });

    test('keeps the exception when the detail has no score', () async {
      final (:service, requests: _) = _service(
        (_) async => _postgrestError({
          'code': 'P0001',
          'message': 'insufficient_score',
          'details': null,
        }),
      );

      expect(
        service.completeLesson(3),
        throwsA(
          isA<InsufficientScoreException>().having(
            (e) => e.average,
            'average',
            isNull,
          ),
        ),
      );
    });

    test('rethrows other server errors unchanged', () async {
      final (:service, requests: _) = _service(
        (_) async =>
            _postgrestError({'code': '22023', 'message': 'invalid_lesson'}),
      );

      expect(service.completeLesson(99), throwsA(isA<PostgrestException>()));
    });
  });

  group('lessonCompletionErrorMessage', () {
    test('explains an insufficient average with the current score', () {
      expect(
        lessonCompletionErrorMessage(
          const InsufficientScoreException(average: 65),
        ),
        "O'rtacha ballingiz 80% dan past (hozirgi: 65%). "
        "Keyingi darsga o'tish uchun bo'limlarni yaxshilang.",
      );
    });

    test('omits the score when it is unknown', () {
      expect(
        lessonCompletionErrorMessage(const InsufficientScoreException()),
        "O'rtacha ballingiz 80% dan past. "
        "Keyingi darsga o'tish uchun bo'limlarni yaxshilang.",
      );
    });
  });
}
