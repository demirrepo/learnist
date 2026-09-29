import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learnist/services/deepgram_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [DeepgramService] on a real [SupabaseClient] whose HTTP calls go to
/// [handler], so functions_client's error handling is exercised too.
DeepgramService _service(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = SupabaseClient(
    'https://example.supabase.co',
    'anon-key',
    httpClient: MockClient(handler),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  addTearDown(client.dispose);
  return DeepgramService(client);
}

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

Matcher _deepgramError(String message, {int? statusCode}) => throwsA(
  isA<DeepgramException>()
      .having((e) => e.message, 'message', message)
      .having((e) => e.statusCode, 'statusCode', statusCode),
);

const _failedMessage =
    "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.";

void main() {
  group('parseTranscript', () {
    test('reads the transcript and trims it', () {
      expect(
        parseTranscript({'transcript': ' Hello, world. '}),
        'Hello, world.',
      );
    });

    test('an empty transcript means no speech was heard', () {
      expect(
        () => parseTranscript({'transcript': '  '}),
        _deepgramError(
          "Ovozingiz aniqlanmadi. Mikrofonga yaqinroq gapirib, qayta urinib "
          "ko'ring.",
        ),
      );
    });

    test('rejects anything else', () {
      for (final data in [
        null,
        'text',
        <Object>[],
        <String, Object>{},
        {'transcript': 1},
        {'error': 'upstream_error'},
      ]) {
        expect(
          () => parseTranscript(data),
          _deepgramError(_failedMessage),
          reason: '$data',
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

    test('uploads the raw audio to transcribe_audio', () async {
      late http.Request sent;
      final service = _service((request) async {
        sent = request;
        return _json({'transcript': 'I like football.'});
      });

      expect(await service.transcribeAudio(audioPath), 'I like football.');
      expect(sent.method, 'POST');
      expect(
        sent.url.toString(),
        'https://example.supabase.co/functions/v1/transcribe_audio',
      );
      expect(sent.headers['Content-Type'], 'audio/mp4');
      // Raw bytes, not base64 or JSON.
      expect(sent.bodyBytes, [1, 2, 3, 4]);
      expect(sent.headers['Authorization'], isNot(startsWith('Token ')));
    });

    test('a WAV fallback recording is labelled as WAV', () async {
      late http.Request sent;
      final service = _service((request) async {
        sent = request;
        return _json({'transcript': 'Hi.'});
      });
      final wav = '${dir.path}/answer.wav';
      File(wav).writeAsBytesSync([5, 6]);

      await service.transcribeAudio(wav);
      expect(sent.headers['Content-Type'], 'audio/wav');
    });

    test('an error status throws with the status code', () async {
      for (final status in [401, 413, 429, 502]) {
        final service = _service(
          (_) async => _json({'error': 'upstream_error'}, status),
        );

        await expectLater(
          service.transcribeAudio(audioPath),
          _deepgramError(_failedMessage, statusCode: status),
          reason: '$status',
        );
      }
    });

    test('a network failure says there is no internet', () async {
      final service = _service(
        (_) async => throw http.ClientException('offline'),
      );

      await expectLater(
        service.transcribeAudio(audioPath),
        _deepgramError("Internet aloqasi yo'q. Iltimos qayta urinib ko'ring."),
      );
    });

    test('checks the file before calling the function', () async {
      var calls = 0;
      final service = _service((_) async {
        calls++;
        return _json({'transcript': 'x'});
      });

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
