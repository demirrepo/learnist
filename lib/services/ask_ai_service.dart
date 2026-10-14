import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// The shared [AskAiService]; overridden with a fake in tests.
final askAiServiceProvider = Provider<AskAiService>((ref) => AskAiService());

/// Why an Ask AI question got no answer; the UI picks the message.
enum AskAiFailure { offline, busy, failed }

class AskAiException implements Exception {
  const AskAiException(this.failure, {this.statusCode});

  final AskAiFailure failure;

  /// Set when `ask-ai` answered with an error status.
  final int? statusCode;

  @override
  String toString() =>
      'AskAiException(${failure.name}'
      '${statusCode == null ? '' : ', $statusCode'})';
}

/// Free-form questions about a lesson through the `ask-ai` Supabase Edge
/// Function. `functions.invoke` sends the signed-in user's JWT, so the
/// function can keep JWT verification on.
class AskAiService {
  AskAiService([SupabaseClient? client])
    : _supabase = client ?? Supabase.instance.client;

  /// Deployed with a hyphen, unlike `evaluate_task`.
  static const function = 'ask-ai';

  /// Free-form answers take longer than a grade.
  static const _timeout = Duration(seconds: 60);

  final SupabaseClient _supabase;

  /// Returns the AI's answer (Markdown) to [prompt], asked about
  /// [lessonContext], e.g. "Lesson 49: Download the app | Grammar | ...".
  ///
  /// Throws an [AskAiException] on a network failure, an error status, a
  /// timeout or an empty answer.
  Future<String> ask(String prompt, String lessonContext) async {
    final FunctionResponse response;
    try {
      response = await _supabase.functions
          .invoke(
            function,
            body: {'prompt': prompt.trim(), 'lessonContext': lessonContext},
          )
          .timeout(_timeout);
    } on FunctionException catch (error) {
      if (kDebugMode) debugPrint('[AskAI] ${error.status}: ${error.details}');
      throw AskAiException(
        error.status == 429 ? AskAiFailure.busy : AskAiFailure.failed,
        statusCode: error.status,
      );
    } on TimeoutException {
      throw const AskAiException(AskAiFailure.failed);
    } on ClientException {
      throw const AskAiException(AskAiFailure.offline);
    } on SocketException {
      throw const AskAiException(AskAiFailure.offline);
    }
    return parseAskAiReply(response.data);
  }
}

/// Reads the answer from an `ask-ai` response, `{"reply": "..."}`. Throws
/// an [AskAiException] when there is no answer.
String parseAskAiReply(Object? data) {
  if (data case {'reply': final String reply} when reply.trim().isNotEmpty) {
    return reply.trim();
  }
  throw const AskAiException(AskAiFailure.failed);
}
