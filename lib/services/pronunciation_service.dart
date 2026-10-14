import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// The shared [PronunciationService]; overridden with a fake in tests.
final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  final service = PronunciationService();
  ref.onDispose(service.stop);
  return service;
});

/// Reads English vocabulary aloud with the device's text-to-speech engine,
/// so it works offline and needs no audio files.
class PronunciationService {
  PronunciationService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  /// Matches the General American IPA shown next to each word.
  static const language = 'en-US';

  final FlutterTts _tts;
  Future<void>? _setup;

  /// Speaks [text], cutting off any word still being spoken.
  Future<void> speak(String text) async {
    try {
      await (_setup ??= _tts.setLanguage(language));
    } catch (_) {
      // Let the next tap try again instead of reusing the failure.
      _setup = null;
      rethrow;
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
