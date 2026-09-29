import 'dart:async';

import 'package:learnist/services/deepgram_service.dart';

/// Records transcribed paths and answers with [transcript], or throws
/// [error]. Set [pending] to hold the answer until it completes.
class FakeDeepgramService implements DeepgramService {
  FakeDeepgramService({this.transcript = 'I like playing football.'});

  String transcript;
  Object? error;
  Completer<void>? pending;

  final List<String> paths = [];

  @override
  Future<String> transcribeAudio(String filePath) async {
    paths.add(filePath);
    await pending?.future;
    if (error case final error?) throw error;
    return transcript;
  }
}
