import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/models/user_stats.dart';
import 'package:learnist/services/progress_service.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../support/fake_progress_service.dart';

/// [userStatsProvider] only listens to the auth service for changes.
class _AuthStub extends ChangeNotifier implements SupabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

  group('saveMistakes', () {
    test('calls upsert_mistakes with the wrong indexes', () async {
      final (:service, :requests) = _service(
        (_) async => http.Response('', 204),
      );

      await service.saveMistakes(3, 'listening', [0, 4]);

      expect(requests.single.url.path, '/rest/v1/rpc/upsert_mistakes');
      expect(jsonDecode(requests.single.body), {
        'p_lesson_number': 3,
        'p_section': 'listening',
        'p_wrong_indexes': [0, 4],
      });
    });

    test('rethrows server errors', () async {
      final (:service, requests: _) = _service(
        (_) async =>
            _postgrestError({'code': '22023', 'message': 'invalid_section'}),
      );

      expect(
        service.saveMistakes(3, 'writing', [1]),
        throwsA(isA<PostgrestException>()),
      );
    });
  });

  group('change notifications', () {
    test('each successful write notifies listeners once', () async {
      final (:service, requests: _) = _service(
        (request) async => http.Response(
          request.url.path.endsWith('complete_lesson') ? '4' : '',
          request.url.path.endsWith('complete_lesson') ? 200 : 204,
        ),
      );
      var notified = 0;
      service.addListener(() => notified++);

      await service.saveSectionScore(3, 'reading', 90);
      expect(notified, 1);
      await service.saveMistakes(3, 'reading', [2]);
      expect(notified, 2);
      await service.completeLesson(3);
      expect(notified, 3);
    });

    test('a failed write does not notify', () async {
      final (:service, requests: _) = _service(
        (_) async =>
            _postgrestError({'code': '22023', 'message': 'invalid_lesson'}),
      );
      var notified = 0;
      service.addListener(() => notified++);

      await expectLater(
        service.saveSectionScore(99, 'reading', 90),
        throwsA(isA<PostgrestException>()),
      );
      await expectLater(
        service.saveMistakes(99, 'reading', [1]),
        throwsA(isA<PostgrestException>()),
      );
      expect(notified, 0);
    });
  });

  test('fetchStats returns zeros without a request when signed out', () async {
    final (:service, :requests) = _service((_) async => http.Response('', 500));

    final stats = await service.fetchStats();

    expect(stats.lessonsMastered, 0);
    expect(stats.trackedMistakes, 0);
    expect(requests, isEmpty);
  });

  group('userStatsProvider', () {
    ProviderContainer containerFor(FakeProgressService progress) {
      final container = ProviderContainer(
        overrides: [
          supabaseServiceProvider.overrideWithValue(_AuthStub()),
          progressServiceProvider.overrideWithValue(progress),
        ],
      );
      addTearDown(container.dispose);
      // Keep the provider alive, as the Home screen does.
      container.listen(userStatsProvider, (_, _) {});
      return container;
    }

    test('refetches after a score, mistakes or a completed lesson', () async {
      final progress = FakeProgressService(
        stats: const UserStats(lessonsMastered: 2, trackedMistakes: 1),
      );
      final container = containerFor(progress);
      expect(
        (await container.read(userStatsProvider.future)).trackedMistakes,
        1,
      );

      final writes = <Future<void> Function()>[
        () => progress.saveSectionScore(3, 'writing', 90),
        () => progress.saveMistakes(3, 'reading', [0, 2]),
        () => progress.completeLesson(3),
      ];
      for (final (i, write) in writes.indexed) {
        progress.stats = UserStats(lessonsMastered: 2, trackedMistakes: i + 2);
        await write();
        final stats = await container.read(userStatsProvider.future);
        expect(stats.trackedMistakes, i + 2);
        expect(progress.statsFetches, i + 2);
      }
    });

    test('a failed write does not refetch', () async {
      final progress = FakeProgressService()..saveScoreError = Exception('x');
      final container = containerFor(progress);
      await container.read(userStatsProvider.future);

      await expectLater(
        progress.saveSectionScore(3, 'writing', 90),
        throwsA(isA<Exception>()),
      );
      await container.read(userStatsProvider.future);
      expect(progress.statsFetches, 1);
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
