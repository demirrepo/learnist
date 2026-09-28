import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An unsigned JWT that expires in an hour; gotrue only decodes it.
String _accessToken() {
  String part(Map<String, Object> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 1));
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'sub': 'user-1', 'exp': exp.millisecondsSinceEpoch ~/ 1000})}'
      '.signature';
}

/// A [SupabaseService] whose password sign-in returns an account saved with
/// [savedRole] metadata (`null`: none, as before roles existed).
({SupabaseService service, SupabaseClient client, List<String> paths}) _service(
  String? savedRole,
) {
  final paths = <String>[];
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient((request) async {
      paths.add(request.url.path);
      if (request.url.path == '/auth/v1/logout') {
        return http.Response('', 204, request: request);
      }
      return http.Response(
        jsonEncode({
          'access_token': _accessToken(),
          'token_type': 'bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh',
          'user': {
            'id': 'user-1',
            'aud': 'authenticated',
            'email': 'a@b.uz',
            'app_metadata': <String, Object>{},
            'user_metadata': {if (savedRole != null) 'role': savedRole},
            'created_at': '2026-09-01T00:00:00Z',
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    }),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  final service = SupabaseService(client);
  addTearDown(() async {
    service.dispose();
    await client.dispose();
  });
  return (service: service, client: client, paths: paths);
}

void main() {
  for (final (saved, picked) in [
    ('student', UserRole.teacher),
    ('teacher', UserRole.student),
    (null, UserRole.teacher),
  ]) {
    test('a $saved account on the ${picked.name} tab is signed out', () async {
      final (:service, :client, :paths) = _service(saved);
      // The sync stream fires while the new session exists, before
      // signInWithPassword returns: what the router could see then.
      final routerSaw = <bool>[];
      // Internal to gotrue, but nothing public observes that window.
      // ignore: invalid_use_of_internal_member
      final events = client.auth.onAuthStateChangeSync.listen(
        (_) => routerSaw.add(service.isSignedIn),
      );
      addTearDown(events.cancel);
      service.addListener(() => routerSaw.add(service.isSignedIn));

      await expectLater(
        service.signIn(email: 'a@b.uz', password: 'secret123', role: picked),
        throwsA(
          isA<RoleMismatchException>().having(
            (e) => e.savedRole,
            'savedRole',
            UserRole.fromMetadata(saved),
          ),
        ),
      );
      await pumpEventQueue();

      expect(service.isSignedIn, isFalse);
      expect(paths, contains('/auth/v1/logout'));
      expect(routerSaw, isNotEmpty);
      expect(routerSaw, everyElement(isFalse));
    });
  }

  test('a matching role stays signed in', () async {
    final (:service, client: _, :paths) = _service('teacher');

    await service.signIn(
      email: 'a@b.uz',
      password: 'secret123',
      role: UserRole.teacher,
    );

    expect(service.isSignedIn, isTrue);
    expect(service.isTeacher, isTrue);
    expect(paths, isNot(contains('/auth/v1/logout')));
  });

  test('the mismatch messages name the tab to pick', () {
    expect(
      authErrorMessage(const RoleMismatchException(UserRole.student)),
      "Siz talaba sifatida ro'yxatdan o'tgansiz. "
      "Iltimos, 'Talaba' bo'limini tanlang.",
    );
    expect(
      authErrorMessage(const RoleMismatchException(UserRole.teacher)),
      "Siz o'qituvchi sifatida ro'yxatdan o'tgansiz. "
      "Iltimos, 'O'qituvchi' bo'limini tanlang.",
    );
  });
}
