import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// The shared [SpeechRecorder]; overridden with a fake in tests.
final speechRecorderProvider = Provider<SpeechRecorder>((ref) {
  final recorder = SpeechRecorder();
  ref.onDispose(recorder.dispose);
  return recorder;
});

enum MicPermission { granted, denied, permanentlyDenied }

/// Records the student's spoken answer to a temporary file for Deepgram.
class SpeechRecorder {
  /// Created on first use, so building the provider touches no plugin.
  AudioRecorder? _recorder;
  AudioRecorder get _audio => _recorder ??= AudioRecorder();

  /// Asks for the microphone if needed. permission_handler covers the
  /// mobile platforms (and reports "never ask again"); elsewhere the
  /// recorder asks the OS itself.
  Future<MicPermission> requestPermission() async {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!mobile) {
      return await _audio.hasPermission()
          ? MicPermission.granted
          : MicPermission.denied;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted || status.isLimited) return MicPermission.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicPermission.permanentlyDenied;
    }
    return MicPermission.denied;
  }

  /// Starts recording to a new file in the temporary directory: AAC where
  /// the platform has it, WAV otherwise. Deepgram takes both.
  Future<void> start() async {
    final aac = await _audio.isEncoderSupported(AudioEncoder.aacLc);
    final dir = await getTemporaryDirectory();
    final name = 'speaking_${DateTime.now().millisecondsSinceEpoch}';
    await _audio.start(
      RecordConfig(
        encoder: aac ? AudioEncoder.aacLc : AudioEncoder.wav,
        numChannels: 1,
      ),
      path: '${dir.path}/$name.${aac ? 'm4a' : 'wav'}',
    );
  }

  /// Stops recording and returns the file's path, or null if nothing was
  /// recorded.
  Future<String?> stop() => _audio.stop();

  /// Stops recording and deletes the file.
  Future<void> cancel() async {
    if (_recorder case final recorder?) await recorder.cancel();
  }

  /// Removes a finished recording once it has been transcribed.
  Future<void> delete(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone; the OS clears the temporary directory anyway.
    }
  }

  Future<void> dispose() async => _recorder?.dispose();
}
