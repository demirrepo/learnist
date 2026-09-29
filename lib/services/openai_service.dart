import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// The shared [OpenAIService]; overridden with a fake in tests.
final openaiServiceProvider = Provider<OpenAIService>(
  (ref) => OpenAIService(),
);

/// Thrown when an AI request can't be completed. [message] is already
/// user-facing (Uzbek), so the UI can show it as-is. [statusCode] is set when
/// the `evaluate_task` function answered with an error.
class OpenAIException implements Exception {
  const OpenAIException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'OpenAIException${statusCode == null ? '' : ' ($statusCode)'}: '
      '$message';
}

/// A graded answer's score (0–100) and Uzbek feedback.
typedef AiEvaluation = ({int score, String feedback});

/// The AI Lab's prompt checker and the lesson tabs' grading, through the
/// `evaluate_task` Supabase Edge Function (see
/// `supabase/functions/evaluate_task/index.ts`).
///
/// The function holds the OpenAI key and the grading instructions; the app
/// only sends which check to run, the student's text and its task.
class OpenAIService {
  OpenAIService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  static const function = 'evaluate_task';

  /// A little over the function's own 30-second limit on OpenAI.
  static const _timeout = Duration(seconds: 35);

  final SupabaseClient _supabase;

  /// Returns the model's feedback on [userPrompt], in Markdown.
  ///
  /// Throws an [OpenAIException] with a user-facing message on a network
  /// failure, an error status, or an empty response.
  Future<String> evaluatePrompt(String userPrompt) async {
    final trimmed = userPrompt.trim();
    if (trimmed.isEmpty) {
      throw const OpenAIException('Avval promptingizni yozing.');
    }
    return _invoke({'kind': 'prompt', 'text': trimmed});
  }

  /// Scores [studentText] (0–100) on its use of [targetGrammar], e.g. the
  /// lesson's `grammar_focus`, with Uzbek feedback.
  ///
  /// Throws an [OpenAIException] like [evaluatePrompt], and also when the
  /// reply isn't the expected JSON.
  Future<AiEvaluation> evaluateGrammar(
    String studentText,
    String targetGrammar,
  ) => _grade('grammar', targetGrammar, studentText);

  /// Scores a written answer to the writing task [topic] on task
  /// achievement, structure and vocabulary. Throws like [evaluateGrammar].
  Future<AiEvaluation> evaluateWriting(String studentText, String topic) =>
      _grade('writing', topic, studentText);

  /// Scores a transcript answering the speaking task [topic] on task
  /// achievement and conversational naturalness. Throws like
  /// [evaluateGrammar].
  Future<AiEvaluation> evaluateSpeaking(String studentText, String topic) =>
      _grade('speaking', topic, studentText);

  Future<AiEvaluation> _grade(
    String kind,
    String context,
    String studentText,
  ) async {
    final trimmed = studentText.trim();
    if (trimmed.isEmpty) {
      throw const OpenAIException('Avval javobingizni yozing.');
    }
    final reply = await _invoke({
      'kind': kind,
      'text': trimmed,
      'context': context.trim(),
    });
    return parseEvaluation(reply);
  }

  /// Runs `evaluate_task` with [body] and returns the model's reply.
  Future<String> _invoke(Map<String, String> body) async {
    final FunctionResponse response;
    try {
      response = await _supabase.functions
          .invoke(function, body: body)
          .timeout(_timeout);
    } on FunctionException catch (error) {
      throw OpenAIException(
        error.status == 429
            ? 'AI hozir band. Birozdan so\'ng qaytadan urinib ko\'ring.'
            : 'AI javob bera olmadi. Qaytadan urinib ko\'ring.',
        statusCode: error.status,
      );
    } on TimeoutException {
      throw const OpenAIException(
        'AI javob bermadi. Qaytadan urinib ko\'ring.',
      );
    } on ClientException {
      throw _offline;
    } on SocketException {
      throw _offline;
    }
    return parseFunctionReply(response.data);
  }
}

const _offline = OpenAIException(
  'Internetga ulanib bo\'lmadi. Qaytadan urinib ko\'ring.',
);

/// Reads `content` from an `evaluate_task` response. Throws an
/// [OpenAIException] if it is missing or blank.
String parseFunctionReply(Object? data) {
  if (data case {'content': final String content}
      when content.trim().isNotEmpty) {
    return content.trim();
  }
  throw const OpenAIException(
    'AI bo\'sh javob qaytardi. Qaytadan urinib ko\'ring.',
  );
}

/// Reads `{"score": 85, "feedback": "..."}` from a grading reply.
///
/// Tolerates a stray code fence and a fractional score; clamps the score
/// to 0–100. Throws a [OpenAIException] for anything else.
AiEvaluation parseEvaluation(String reply) {
  const invalid = OpenAIException(
    'AI javobini o\'qib bo\'lmadi. Qaytadan urinib ko\'ring.',
  );
  final json = reply
      .trim()
      .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
      .replaceFirst(RegExp(r'\s*```$'), '');

  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    throw invalid;
  }

  if (decoded case {
    'score': final num score,
    'feedback': final String feedback,
  } when score.isFinite && feedback.trim().isNotEmpty) {
    return (score: score.round().clamp(0, 100), feedback: feedback.trim());
  }
  throw invalid;
}
