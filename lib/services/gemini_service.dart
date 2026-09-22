import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Thrown when the prompt evaluation can't be completed. [message] is already
/// user-facing (Uzbek), so the UI can show it as-is.
class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => 'GeminiException: $message';
}

/// Wraps the Gemini text model used by the AI Lab.
///
/// A singleton so the model (and its HTTP client) is built once and reused
/// across rebuilds of the prompt checker.
class GeminiService {
  factory GeminiService() => _instance;

  GeminiService._();

  static final GeminiService _instance = GeminiService._();

  /// `gemini-1.5-flash` and `gemini-2.5-flash` are both closed to new API
  /// keys, so we use the current flash model. Swap here when it rolls over.
  static const _modelName = 'gemini-3.6-flash';

  static const _systemInstruction =
      'You are an expert AI prompt evaluator for a university English learning '
      'app. The user will provide a prompt they intend to use. Evaluate their '
      'prompt based on 5 criteria: Role, Task, Level, Context, and Format. '
      'Give brief, constructive feedback in Uzbek or English. Highlight what '
      'is missing and suggest a small improvement. Keep the response under 4 '
      'sentences.';

  GenerativeModel? _model;

  /// Built on first use: [dotenv] is only loaded after `main()` runs.
  GenerativeModel get _generativeModel {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const GeminiException(
        'GEMINI_API_KEY topilmadi. .env faylini tekshiring.',
      );
    }
    return _model ??= GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(_systemInstruction),
    );
  }

  /// Returns the model's feedback on [userPrompt].
  ///
  /// Throws a [GeminiException] with a user-facing message on a missing key,
  /// a network failure, or an empty/blocked response.
  Future<String> evaluatePrompt(String userPrompt) async {
    final trimmed = userPrompt.trim();
    if (trimmed.isEmpty) {
      throw const GeminiException('Avval promptingizni yozing.');
    }

    final GenerateContentResponse response;
    try {
      response = await _generativeModel.generateContent([
        Content.text(trimmed),
      ]);
    } on GeminiException {
      rethrow;
    } on GenerativeAIException catch (error) {
      throw GeminiException('AI javob bera olmadi: ${error.message}');
    } catch (_) {
      throw const GeminiException(
        'Internetga ulanib bo\'lmadi. Qaytadan urinib ko\'ring.',
      );
    }

    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw const GeminiException(
        'AI bo\'sh javob qaytardi. Qaytadan urinib ko\'ring.',
      );
    }
    return text;
  }
}
