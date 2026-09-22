import 'dart:convert';

/// One row of the Supabase `lessons` table.
///
/// Required columns throw a [FormatException] when missing or mistyped, so a
/// broken row fails loudly instead of rendering as an empty lesson. Nullable
/// text columns treat blank strings as null.
class Lesson {
  const Lesson({
    required this.lessonNumber,
    required this.originalNumber,
    required this.semester,
    required this.title,
    required this.grammarFocus,
    required this.cefrLevel,
    this.topic,
    this.taskMeta = const [],
    this.grammarRules,
    this.grammarRulesSource,
    this.readingPassage,
    this.readingFormat,
    this.readingVocabulary = const [],
    this.readingQuestions = const [],
    this.listeningTranscript,
    this.listeningFormat,
    this.listeningSpeakers = const [],
    this.listeningQuestions = const [],
    this.writingPrompt,
    this.speakingPrompt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonNumber: _requiredInt(json, 'lesson_number'),
      originalNumber: _requiredInt(json, 'original_number'),
      semester: _requiredInt(json, 'semester'),
      title: _requiredString(json, 'title'),
      grammarFocus: _requiredString(json, 'grammar_focus'),
      cefrLevel: _requiredString(json, 'cefr_level'),
      topic: _optionalString(json['topic']),
      taskMeta: _stringList(json['task_meta']),
      grammarRules: _optionalString(json['grammar_rules']),
      grammarRulesSource: _optionalString(json['grammar_rules_source']),
      readingPassage: _optionalString(json['reading_passage']),
      readingFormat: _optionalString(json['reading_format']),
      readingVocabulary: _jsonList(json['reading_vocabulary']),
      readingQuestions: _jsonList(json['reading_questions']),
      listeningTranscript: _optionalString(json['listening_transcript']),
      listeningFormat: _optionalString(json['listening_format']),
      listeningSpeakers: _stringList(json['listening_speakers']),
      listeningQuestions: _jsonList(json['listening_questions']),
      writingPrompt: _optionalString(json['writing_prompt']),
      speakingPrompt: _optionalString(json['speaking_prompt']),
    );
  }

  /// Position in the 52-lesson pathway, 1 – 52.
  final int lessonNumber;

  /// Number within its semester, as printed in the course book.
  final int originalNumber;
  final int semester;
  final String title;
  final String grammarFocus;
  final String cefrLevel;
  final String? topic;
  final List<String> taskMeta;

  /// Uzbek explanation of the lesson's grammar.
  final String? grammarRules;

  /// `lesson`, or `site_fallback_guide` when [grammarRules] is the generic
  /// category guide used because the lesson had no rule of its own.
  final String? grammarRulesSource;
  final String? readingPassage;
  final String? readingFormat;

  /// `{word, definition, example}` objects from the JSONB column.
  final List<dynamic> readingVocabulary;

  /// `{question, options, answer_index, hint}` objects from the JSONB column.
  final List<dynamic> readingQuestions;

  /// "Speaker: line" pairs separated by newlines.
  final String? listeningTranscript;
  final String? listeningFormat;
  final List<String> listeningSpeakers;

  /// Same shape as [readingQuestions].
  final List<dynamic> listeningQuestions;
  final String? writingPrompt;
  final String? speakingPrompt;

  bool get isFallbackGrammarRule => grammarRulesSource == 'site_fallback_guide';

  @override
  String toString() => 'Lesson($lessonNumber: $title)';
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  // PostgREST returns smallint as int, but tolerate 1.0 or "1".
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  throw FormatException('Lesson column "$key" must be an integer', value);
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json[key]);
  if (value == null) {
    throw FormatException('Lesson column "$key" is required', json[key]);
  }
  return value;
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// `text[]` column: keeps non-blank strings, drops anything else.
List<String> _stringList(Object? value) {
  return List.unmodifiable([
    for (final item in _jsonList(value))
      if (_optionalString(item) case final text?) text,
  ]);
}

/// JSONB array column. supabase_flutter already decodes it to a List, but a
/// value stored as a JSON string is decoded too. Anything else is empty.
List<dynamic> _jsonList(Object? value) {
  if (value is List) return List.unmodifiable(value);
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) return List.unmodifiable(decoded);
    } on FormatException {
      // Not JSON; fall through to empty.
    }
  }
  return const [];
}
