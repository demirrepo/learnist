import 'package:learnist/services/pronunciation_service.dart';

/// Records what would be spoken instead of using the device's TTS engine.
class FakePronunciationService implements PronunciationService {
  final List<String> spoken = [];

  /// Thrown by [speak], e.g. when no English voice is installed.
  Object? error;

  @override
  Future<void> speak(String text) async {
    if (error case final error?) throw error;
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}
