import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/deepgram_service.dart';

String _response(String transcript) => jsonEncode({
  'results': {
    'channels': [
      {
        'alternatives': [
          {'transcript': transcript, 'confidence': 0.98},
        ],
      },
    ],
  },
});

Matcher _deepgramError(String message, {int? statusCode}) => throwsA(
  isA<DeepgramException>()
      .having((e) => e.message, 'message', message)
      .having((e) => e.statusCode, 'statusCode', statusCode),
);

const _failedMessage =
    "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.";

void main() {
  group('parseTranscript', () {
    test('reads the first alternative and trims it', () {
      expect(parseTranscript(_response(' Hello, world. ')), 'Hello, world.');
    });

    test('an empty transcript means no speech was heard', () {
      expect(
        () => parseTranscript(_response('  ')),
        _deepgramError(
          "Ovozingiz aniqlanmadi. Mikrofonga yaqinroq gapirib, qayta urinib "
          "ko'ring.",
        ),
      );
    });

    test('rejects anything else', () {
      for (final body in [
        'not json',
        '[]',
        '{}',
        '{"results": {"channels": []}}',
        '{"results": {"channels": [{"alternatives": []}]}}',
        '{"results": {"channels": [{"alternatives": [{"transcript": 1}]}]}}',
      ]) {
        expect(
          () => parseTranscript(body),
          _deepgramError(_failedMessage),
          reason: body,
        );
      }
    });
  });

  group('transcribeAudio', () {
    late Directory dir;
    late String audioPath;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('deepgram_test');
      audioPath = '${dir.path}/answer.m4a';
      File(audioPath).writeAsBytesSync([1, 2, 3, 4]);
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('posts the raw audio to Nova-2 and returns the transcript', () async {
      late http.Request sent;
      final service = DeepgramService(
        apiKey: 'secret',
        client: MockClient((request) async {
          sent = request;
          return http.Response(_response('I like football.'), 200);
        }),
      );

      expect(await service.transcribeAudio(audioPath), 'I like football.');
      expect(sent.method, 'POST');
      expect(sent.url.host, 'api.deepgram.com');
      expect(sent.url.path, '/v1/listen');
      expect(sent.url.queryParameters, {
        'model': 'nova-2',
        'smart_format': 'true',
        'language': 'en',
      });
      expect(sent.headers['Authorization'], 'Token secret');
      expect(sent.headers['Content-Type'], 'audio/mp4');
      expect(sent.bodyBytes, [1, 2, 3, 4]);
    });

    test('an error status throws with the status code', () async {
      final service = DeepgramService(
        apiKey: 'secret',
        client: MockClient(
          (_) async => http.Response('{"err_msg": "Invalid credentials"}', 401),
        ),
      );

      await expectLater(
        service.transcribeAudio(audioPath),
        _deepgramError(_failedMessage, statusCode: 401),
      );
    });

    test('a network failure says there is no internet', () async {
      final service = DeepgramService(
        apiKey: 'secret',
        client: MockClient((_) async => throw http.ClientException('offline')),
      );

      await expectLater(
        service.transcribeAudio(audioPath),
        _deepgramError("Internet aloqasi yo'q. Iltimos qayta urinib ko'ring."),
      );
    });

    test('checks the key and the file before calling Deepgram', () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response(_response('x'), 200);
      });

      await expectLater(
        DeepgramService(apiKey: '', client: client).transcribeAudio(audioPath),
        _deepgramError('DEEPGRAM_API_KEY topilmadi. .env faylini tekshiring.'),
      );
      final service = DeepgramService(apiKey: 'secret', client: client);
      await expectLater(
        service.transcribeAudio('${dir.path}/missing.m4a'),
        _deepgramError('Yozib olingan audio topilmadi.'),
      );
      File(audioPath).writeAsBytesSync([]);
      await expectLater(
        service.transcribeAudio(audioPath),
        _deepgramError("Yozib olingan audio bo'sh."),
      );
      expect(calls, 0);
    });
  });
}
