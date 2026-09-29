import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/models/teacher_dashboard.dart';
import 'package:learnist/services/teacher_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An unsigned JWT that expires in an hour; gotrue only decodes it.
String _accessToken() {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': 'teacher-1', 'exp': exp.millisecondsSinceEpoch ~/ 1000})}'
      '.signature';
}

/// A [TeacherService] on a real [SupabaseClient] whose HTTP calls go to
/// [handler], so PostgREST's error decoding is exercised too.
Future<({TeacherService service, List<http.Request> requests})> _service(
  Future<http.Response> Function(http.Request request) handler, {
  bool signedIn = true,
}) async {
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
  if (signedIn) {
    // An unexpired stored session is restored without a request.
    final expiresAt = DateTime.now().add(const Duration(hours: 1));
    await client.auth.recoverSession(
      jsonEncode({
        'access_token': _accessToken(),
        'token_type': 'bearer',
        'expires_in': 3600,
        'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'refresh_token': 'refresh',
        'user': {
          'id': 'teacher-1',
          'aud': 'authenticated',
          'app_metadata': <String, Object>{},
          'user_metadata': {'role': 'teacher'},
          'created_at': '2026-09-01T00:00:00Z',
        },
      }),
    );
  }
  return (service: TeacherService(client), requests: requests);
}

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

http.Response _postgrestError(Map<String, Object?> body) => _json(body, 400);

void main() {
  group('fetchDashboard', () {
    test('parses the stats, groups and students', () async {
      final (:service, :requests) = await _service(
        (_) async => _json({
          'total_students': 2,
          'total_groups': 2,
          'average_mastery': 87,
          'groups': [
            {
              'id': 'g1',
              'name': 'English group 301',
              'login_code': 'ELT301',
              'password': 'elt301',
              'students': [
                {
                  'id': 's1',
                  'full_name': 'Demirbek Razzaqov',
                  'username': 'redscorpnoir',
                  'current_lesson': 3,
                  'mastery': 93,
                  'cefr_level': 'C1',
                },
                {
                  'id': 's2',
                  'full_name': null,
                  'username': null,
                  'current_lesson': null,
                  'mastery': 81,
                  'cefr_level': null,
                },
              ],
            },
            {
              'id': 'g2',
              'name': 'Evening',
              'login_code': 'EVE',
              'password': 'pass',
              'students': <Object>[],
            },
          ],
        }),
      );

      final dashboard = await service.fetchDashboard();

      expect(requests.single.url.path, '/rest/v1/rpc/get_teacher_dashboard');
      expect(dashboard.totalStudents, 2);
      expect(dashboard.totalGroups, 2);
      expect(dashboard.averageMastery, 87);
      expect(dashboard.groups.map((g) => g.name), [
        'English group 301',
        'Evening',
      ]);
      final group = dashboard.groups.first;
      expect((group.login, group.password), ('ELT301', 'elt301'));
      final [first, second] = group.students;
      expect(first.id, 's1');
      expect(first.username, 'redscorpnoir');
      expect(first.currentLesson, 3);
      expect(first.masteryPercent, 93);
      expect(first.cefrLevel, 'C1');
      // Missing values fall back instead of throwing.
      expect(second.fullName, 'Talaba');
      expect(second.username, isNull);
      expect(second.currentLesson, 1);
      expect(second.cefrLevel, isNull);
      expect(dashboard.groups.last.students, isEmpty);
    });

    test(
      'returns an empty dashboard without a request when signed out',
      () async {
        final (:service, :requests) = await _service(
          (_) async => http.Response('', 500),
          signedIn: false,
        );

        final dashboard = await service.fetchDashboard();

        expect(dashboard.groups, isEmpty);
        expect(requests, isEmpty);
      },
    );

    test('rethrows server errors', () async {
      final (:service, requests: _) = await _service(
        (_) async => _postgrestError({'code': '42501', 'message': 'denied'}),
      );

      expect(service.fetchDashboard(), throwsA(isA<PostgrestException>()));
    });
  });

  group('fetchStudentLessons', () {
    test('sends the student id and parses each lesson', () async {
      final (:service, :requests) = await _service(
        (_) async => _json([
          {
            'lesson_number': 2,
            'title': 'A world of sport',
            'is_current': true,
            'grammar': 0,
            'reading': 100,
            'listening': 40,
            'writing': 0,
            'speaking': 0,
          },
          {
            'lesson_number': 1,
            'title': null,
            'is_current': false,
            'grammar': 85,
            'reading': 90,
            'listening': 80,
            'writing': 75,
            'speaking': 70,
          },
          // Unusable rows are skipped.
          {'lesson_number': 0},
        ]),
      );

      final lessons = await service.fetchStudentLessons('s1');

      expect(requests.single.url.path, '/rest/v1/rpc/get_student_detail');
      expect(jsonDecode(requests.single.body), {'p_student_id': 's1'});
      expect(lessons, hasLength(2));
      expect(lessons.first.isCurrent, isTrue);
      expect(lessons.first.skills, [
        ('Grammar', 0),
        ('Reading', 100),
        ('Listening', 40),
        ('Writing', 0),
        ('Speaking', 0),
      ]);
      expect(lessons.last.title, 'Lesson 1');
      expect(lessons.last.grammar, 85);
    });

    test('rethrows student_not_found', () async {
      final (:service, requests: _) = await _service(
        (_) async =>
            _postgrestError({'code': 'P0002', 'message': 'student_not_found'}),
      );

      expect(
        service.fetchStudentLessons('someone-else'),
        throwsA(isA<PostgrestException>()),
      );
    });
  });

  group('joinGroup', () {
    test('sends the normalized login and trimmed password', () async {
      final (:service, :requests) = await _service(
        (_) async =>
            _json({'group_name': 'English group 301', 'already_member': false}),
      );

      final result = await service.joinGroup(
        login: ' elt301 ',
        password: ' elt301 ',
      );

      expect(requests.single.url.path, '/rest/v1/rpc/join_group');
      expect(jsonDecode(requests.single.body), {
        'p_login_code': 'ELT301',
        'p_password': 'elt301',
      });
      expect(result.groupName, 'English group 301');
      expect(result.alreadyMember, isFalse);
      expect(
        joinGroupSuccessMessage(result),
        "«English group 301» guruhiga qo'shildingiz.",
      );
    });

    test('reports an existing membership', () async {
      final (:service, requests: _) = await _service(
        (_) async => _json({'group_name': 'Evening', 'already_member': true}),
      );

      final result = await service.joinGroup(login: 'EVE', password: 'pass');

      expect(result.alreadyMember, isTrue);
      expect(
        joinGroupSuccessMessage(result),
        'Siz allaqachon «Evening» guruhidasiz.',
      );
    });

    test('turns invalid_credentials into its exception', () async {
      final (:service, requests: _) = await _service(
        (_) async => _postgrestError({
          'code': 'P0001',
          'message': 'invalid_credentials',
        }),
      );

      await expectLater(
        service.joinGroup(login: 'ELT301', password: 'wrong'),
        throwsA(isA<InvalidGroupCredentialsException>()),
      );
      expect(
        joinGroupErrorMessage(const InvalidGroupCredentialsException()),
        "Login yoki parol noto'g'ri.",
      );
    });

    test('turns own_group into its exception', () async {
      final (:service, requests: _) = await _service(
        (_) async => _postgrestError({'code': 'P0001', 'message': 'own_group'}),
      );

      expect(
        service.joinGroup(login: 'ELT301', password: 'elt301'),
        throwsA(isA<OwnGroupException>()),
      );
    });

    test('rethrows other server errors unchanged', () async {
      final (:service, requests: _) = await _service(
        (_) async =>
            _postgrestError({'code': '28000', 'message': 'not_authenticated'}),
      );

      await expectLater(
        service.joinGroup(login: 'ELT301', password: 'elt301'),
        throwsA(isA<PostgrestException>()),
      );
      expect(
        joinGroupErrorMessage(const PostgrestException(message: 'x')),
        "Guruhga qo'shilib bo'lmadi. Iltimos, qayta urinib ko'ring.",
      );
    });
  });

  group('createGroup', () {
    test('inserts the normalized group', () async {
      final (:service, :requests) = await _service(
        (_) async => http.Response('', 201),
      );

      await service.createGroup(
        name: ' English group 301 ',
        login: 'elt301',
        password: ' elt301 ',
      );

      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/rest/v1/student_groups');
      expect(jsonDecode(requests.single.body), {
        'name': 'English group 301',
        'login_code': 'ELT301',
        'password': 'elt301',
      });
    });

    test('a taken login throws GroupLoginTakenException', () async {
      final (:service, requests: _) = await _service(
        (_) async => _postgrestError({
          'code': '23505',
          'message': 'duplicate key value violates unique constraint',
        }),
      );

      await expectLater(
        service.createGroup(name: 'A', login: 'ELT301', password: 'pass'),
        throwsA(isA<GroupLoginTakenException>()),
      );
      expect(
        createGroupErrorMessage(const GroupLoginTakenException()),
        'Bu login band. Iltimos, boshqa login tanlang.',
      );
    });
  });

  test('the login pattern matches the database check', () {
    for (final login in ['ELT301', 'A-B_C', 'ABC']) {
      expect(
        TeacherService.loginPattern.hasMatch(login),
        isTrue,
        reason: login,
      );
    }
    for (final login in ['AB', 'elt301', 'ELT 301', 'X' * 33, 'ÉLT']) {
      expect(
        TeacherService.loginPattern.hasMatch(login),
        isFalse,
        reason: login,
      );
    }
  });

  test('TeacherDashboard.fromJson tolerates a null or malformed body', () {
    expect(TeacherDashboard.fromJson(null).groups, isEmpty);
    final dashboard = TeacherDashboard.fromJson({
      'total_students': '3',
      'average_mastery': 140,
      'groups': 'nope',
    });
    expect(dashboard.totalStudents, 3);
    expect(dashboard.averageMastery, 100);
    expect(dashboard.groups, isEmpty);
  });
}
