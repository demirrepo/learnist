import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// Pretends to play a recording without touching just_audio's platform.
class FakeAudioPlayer implements AudioPlayer {
  final _states = StreamController<PlayerState>.broadcast();

  /// Thrown by [setFilePath], e.g. for an unreadable file.
  Object? loadError;
  Duration fileDuration = const Duration(seconds: 42);

  String? filePath;
  bool disposed = false;
  bool _playing = false;

  @override
  bool get playing => _playing;

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  Stream<Duration?> get durationStream => Stream.value(fileDuration);

  @override
  Stream<Duration> get positionStream => Stream.value(Duration.zero);

  @override
  Future<Duration?> setFilePath(
    String filePath, {
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    if (loadError case final error?) throw error;
    this.filePath = filePath;
    return fileDuration;
  }

  @override
  Future<void> play() async => _setPlaying(true);

  @override
  Future<void> pause() async => _setPlaying(false);

  @override
  Future<void> seek(Duration? position, {int? index}) async {}

  @override
  Future<void> dispose() async {
    disposed = true;
    _playing = false;
    await _states.close();
  }

  void _setPlaying(bool playing) {
    _playing = playing;
    _states.add(PlayerState(playing, ProcessingState.ready));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
