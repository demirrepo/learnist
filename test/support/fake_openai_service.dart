import 'dart:async';

import 'package:learnist/services/openai_service.dart';

typedef GradingCall = ({String section, String studentText, String topic});

/// Records grading calls and answers with [result], or throws [error].
/// Set [pending] to hold the answer until it completes. The prompt checker
/// gets [promptFeedback] and records its prompts in [prompts].
class FakeOpenAIService implements OpenAIService {
  FakeOpenAIService({
    this.result = (score: 85, feedback: 'Juda yaxshi!'),
    this.promptFeedback = 'Yaxshi prompt.',
    this.error,
  });

  AiEvaluation result;
  String promptFeedback;
  Object? error;
  Completer<void>? pending;

  final List<GradingCall> calls = [];
  final List<String> prompts = [];

  Future<AiEvaluation> _grade(
    String section,
    String studentText,
    String topic,
  ) async {
    calls.add((section: section, studentText: studentText, topic: topic));
    await pending?.future;
    if (error case final error?) throw error;
    return result;
  }

  @override
  Future<AiEvaluation> evaluateGrammar(
    String studentText,
    String targetGrammar,
  ) => _grade('grammar', studentText, targetGrammar);

  @override
  Future<AiEvaluation> evaluateWriting(String studentText, String topic) =>
      _grade('writing', studentText, topic);

  @override
  Future<AiEvaluation> evaluateSpeaking(String studentText, String topic) =>
      _grade('speaking', studentText, topic);

  @override
  Future<String> evaluatePrompt(String userPrompt) async {
    prompts.add(userPrompt);
    await pending?.future;
    if (error case final error?) throw error;
    return promptFeedback;
  }

  @override
  void close() {}
}
