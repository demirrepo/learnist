import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

/// The shared [DeepgramService]; overridden with a fake in tests.
final deepgramServiceProvider = Provider<DeepgramService>(
  (ref) => DeepgramService(),
);

/// Why a recording couldn't be transcribed.
enum DeepgramFailure {
  recordingMissing,
  recordingEmpty,
  failed,
  timeout,
  offline,
  noSpeech,
}

/// Thrown when a recording can't be transcribed. [message] gives the
/// user-facing reason in the app's language. [statusCode] is set when the
/// `transcribe_audio` function answered with an error.
class DeepgramException implements Exception {
  const DeepgramException(this.failure, {this.statusCode});

  final DeepgramFailure failure;
  final int? statusCode;

  String message(AppLocalizations l10n) => switch (failure) {
    DeepgramFailure.recordingMissing => l10n.taskRecordingMissing,
    DeepgramFailure.recordingEmpty => l10n.recordingEmpty,
    DeepgramFailure.failed => l10n.taskTranscriptionError,
    DeepgramFailure.timeout => l10n.errorNoResponse,
    DeepgramFailure.offline => l10n.errorOffline,
    DeepgramFailure.noSpeech => l10n.transcriptionNoSpeech,
  };

  @override
  String toString() =>
      'DeepgramException${statusCode == null ? '' : ' ($statusCode)'}: '
      '${failure.name}';
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
      throw const DeepgramException(DeepgramFailure.recordingMissing);
    }
    if (audio.isEmpty) {
      throw const DeepgramException(DeepgramFailure.recordingEmpty);
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
      throw DeepgramException(DeepgramFailure.failed, statusCode: error.status);
    } on TimeoutException {
      throw const DeepgramException(DeepgramFailure.timeout);
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

const _offline = DeepgramException(DeepgramFailure.offline);

/// Reads `transcript` from a `transcribe_audio` response. Silence comes
/// back as an empty transcript, which is an error here: there is nothing
/// for the student to review.
String parseTranscript(Object? data) {
  if (data case {'transcript': final String transcript}) {
    final text = transcript.trim();
    if (text.isEmpty) {
      throw const DeepgramException(DeepgramFailure.noSpeech);
    }
    return text;
  }
  throw const DeepgramException(DeepgramFailure.failed);
}
