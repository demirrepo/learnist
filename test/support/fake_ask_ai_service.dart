import 'dart:async';

import 'package:learnist/services/ask_ai_service.dart';

/// Answers with [answer] without calling Supabase.
///
/// Set [error] to make questions fail, or [pending] to hold the answer until
/// it completes.
class FakeAskAiService implements AskAiService {
  FakeAskAiService({this.answer = '**Hint:** check the verb form.'});

  String answer;
  Object? error;
  Completer<void>? pending;
  final List<({String prompt, String lessonContext})> questions = [];

  @override
  Future<String> ask(String prompt, String lessonContext) async {
    questions.add((prompt: prompt, lessonContext: lessonContext));
    if (pending case final completer?) await completer.future;
    if (error case final error?) throw error;
    return answer;
  }
}
