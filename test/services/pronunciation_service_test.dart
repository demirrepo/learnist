import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:learnist/services/pronunciation_service.dart';

/// Logs the engine calls instead of going through the platform channel.
class _FakeTts implements FlutterTts {
  final List<String> calls = [];
  Object? languageError;

  @override
  Future<dynamic> setLanguage(String language) async {
    calls.add('setLanguage $language');
    if (languageError case final error?) throw error;
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    calls.add('stop');
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    calls.add('speak $text');
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('speaks in American English, setting the voice up once', () async {
    final tts = _FakeTts();
    final service = PronunciationService(tts);

    await service.speak('classmate');
    await service.speak('hometown');

    expect(tts.calls, [
      'setLanguage en-US',
      'stop',
      'speak classmate',
      'stop',
      'speak hometown',
    ]);
  });

  test('a failed setup is retried on the next word', () async {
    final tts = _FakeTts()..languageError = Exception('no voice');
    final service = PronunciationService(tts);

    await expectLater(service.speak('cloud'), throwsException);
    tts.languageError = null;
    await service.speak('cloud');

    expect(tts.calls, [
      'setLanguage en-US',
      'setLanguage en-US',
      'stop',
      'speak cloud',
    ]);
  });
}
