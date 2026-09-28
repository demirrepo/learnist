import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// The shared [DeepgramService]; overridden with a fake in tests.
final deepgramServiceProvider = Provider<DeepgramService>((ref) {
  final service = DeepgramService();
  ref.onDispose(service.close);
  return service;
});

/// Thrown when a recording can't be transcribed. [message] is already
/// user-facing (Uzbek), so the UI can show it as-is. [statusCode] is set when
/// Deepgram answered with an error.
class DeepgramException implements Exception {
  const DeepgramException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'DeepgramException${statusCode == null ? '' : ' ($statusCode)'}: '
      '$message';
}

/// Speech-to-text for the speaking tab via Deepgram's pre-recorded REST API
/// (Nova-2), which is steadier on mobile networks than streaming.
class DeepgramService {
  /// [apiKey] defaults to `DEEPGRAM_API_KEY` from `.env`.
  DeepgramService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKeyOverride = apiKey;

  static final endpoint = Uri.https('api.deepgram.com', '/v1/listen', {
    'model': 'nova-2',
    'smart_format': 'true',
    'language': 'en',
  });

  /// Long enough to upload a five-minute answer on a slow connection.
  static const _timeout = Duration(seconds: 60);

  final http.Client _client;
  final String? _apiKeyOverride;

  /// Read on first use: [dotenv] is only loaded after `main()` runs.
  String get _apiKey {
    final apiKey = _apiKeyOverride ?? dotenv.env['DEEPGRAM_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const DeepgramException(
        'DEEPGRAM_API_KEY topilmadi. .env faylini tekshiring.',
      );
    }
    return apiKey;
  }

  /// Uploads the audio file at [filePath] and returns what was said.
  Future<String> transcribeAudio(String filePath) async {
    final apiKey = _apiKey;

    final List<int> audio;
    try {
      audio = await File(filePath).readAsBytes();
    } on FileSystemException {
      throw const DeepgramException("Yozib olingan audio topilmadi.");
    }
    if (audio.isEmpty) {
      throw const DeepgramException("Yozib olingan audio bo'sh.");
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: {
              'Authorization': 'Token $apiKey',
              'Content-Type': _contentType(filePath),
            },
            body: audio,
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const DeepgramException(
        "Server javob bermadi. Iltimos qayta urinib ko'ring.",
      );
    } on http.ClientException {
      throw const DeepgramException(
        "Internet aloqasi yo'q. Iltimos qayta urinib ko'ring.",
      );
    } on SocketException {
      throw const DeepgramException(
        "Internet aloqasi yo'q. Iltimos qayta urinib ko'ring.",
      );
    }

    if (response.statusCode != 200) {
      throw DeepgramException(
        "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.",
        statusCode: response.statusCode,
      );
    }
    return parseTranscript(response.body);
  }

  void close() => _client.close();

  static String _contentType(String filePath) => switch (filePath
      .split('.')
      .last
      .toLowerCase()) {
    'm4a' || 'mp4' || 'aac' => 'audio/mp4',
    'wav' => 'audio/wav',
    'mp3' => 'audio/mpeg',
    'ogg' || 'opus' => 'audio/ogg',
    'flac' => 'audio/flac',
    _ => 'application/octet-stream',
  };
}

/// Reads `results.channels[0].alternatives[0].transcript` from a Deepgram
/// response. Silence comes back as an empty transcript, which is an error
/// here: there is nothing for the student to review.
String parseTranscript(String body) {
  const malformed = DeepgramException(
    "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.",
  );
  final Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException {
    throw malformed;
  }
  if (json case {
    'results': {
      'channels': [
        {'alternatives': [{'transcript': final String transcript}, ...]},
        ...,
      ],
    },
  }) {
    final text = transcript.trim();
    if (text.isEmpty) {
      throw const DeepgramException(
        "Ovozingiz aniqlanmadi. Mikrofonga yaqinroq gapirib, qayta urinib "
        "ko'ring.",
      );
    }
    return text;
  }
  throw malformed;
}
