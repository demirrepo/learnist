import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// The shared [DeepgramService]; overridden with a fake in tests.
final deepgramServiceProvider = Provider<DeepgramService>(
  (ref) => DeepgramService(),
);

/// Thrown when a recording can't be transcribed. [message] is already
/// user-facing (Uzbek), so the UI can show it as-is. [statusCode] is set when
/// the `transcribe_audio` function answered with an error.
class DeepgramException implements Exception {
  const DeepgramException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'DeepgramException${statusCode == null ? '' : ' ($statusCode)'}: '
      '$message';
}

/// Speech-to-text for the speaking tab through the `transcribe_audio`
/// Supabase Edge Function (see
/// `supabase/functions/transcribe_audio/index.ts`), which holds the
/// Deepgram key and calls its pre-recorded Nova-2 API.
class DeepgramService {
  DeepgramService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  static const function = 'transcribe_audio';

  /// Long enough to upload a five-minute answer on a slow connection, a
  /// little over the function's own 60-second limit on Deepgram.
  static const _timeout = Duration(seconds: 70);

  final SupabaseClient _supabase;

  /// Uploads the audio file at [filePath] and returns what was said.
  Future<String> transcribeAudio(String filePath) async {
    final Uint8List audio;
    try {
      audio = await File(filePath).readAsBytes();
    } on FileSystemException {
      throw const DeepgramException("Yozib olingan audio topilmadi.");
    }
    if (audio.isEmpty) {
      throw const DeepgramException("Yozib olingan audio bo'sh.");
    }

    final FunctionResponse response;
    try {
      response = await _supabase.functions
          .invoke(
            function,
            headers: {'Content-Type': _contentType(filePath)},
            body: audio,
          )
          .timeout(_timeout);
    } on FunctionException catch (error) {
      throw DeepgramException(
        "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.",
        statusCode: error.status,
      );
    } on TimeoutException {
      throw const DeepgramException(
        "Server javob bermadi. Iltimos qayta urinib ko'ring.",
      );
    } on ClientException {
      throw _offline;
    } on SocketException {
      throw _offline;
    }
    return parseTranscript(response.data);
  }

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

const _offline = DeepgramException(
  "Internet aloqasi yo'q. Iltimos qayta urinib ko'ring.",
);

/// Reads `transcript` from a `transcribe_audio` response. Silence comes
/// back as an empty transcript, which is an error here: there is nothing
/// for the student to review.
String parseTranscript(Object? data) {
  if (data case {'transcript': final String transcript}) {
    final text = transcript.trim();
    if (text.isEmpty) {
      throw const DeepgramException(
        "Ovozingiz aniqlanmadi. Mikrofonga yaqinroq gapirib, qayta urinib "
        "ko'ring.",
      );
    }
    return text;
  }
  throw const DeepgramException(
    "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.",
  );
}
