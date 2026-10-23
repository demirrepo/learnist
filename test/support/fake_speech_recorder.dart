import 'dart:async';

import 'package:learnist/services/speech_recorder.dart';

/// Pretends to record to [path] without touching the microphone.
class FakeSpeechRecorder implements SpeechRecorder {
  FakeSpeechRecorder({this.permission = MicPermission.granted});

  MicPermission permission;

  /// Thrown by [start], e.g. when the microphone is busy.
  Object? startError;
  String? path = '/tmp/speaking.m4a';

  /// When set, [stop] waits for it, e.g. to leave the lesson meanwhile.
  Completer<void>? stopDelay;

  bool recording = false;
  int cancelCount = 0;
  final List<String> deleted = [];

  @override
  Future<MicPermission> requestPermission() async => permission;

  @override
  Future<void> start() async {
    if (startError case final error?) throw error;
    recording = true;
  }

  @override
  Future<String?> stop() async {
    await stopDelay?.future;
    recording = false;
    return path;
  }

  @override
  Future<void> cancel() async {
    recording = false;
    cancelCount++;
  }

  @override
  Future<void> delete(String path) async => deleted.add(path);

  @override
  Future<void> dispose() async {}
}
