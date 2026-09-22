import 'user_progress.dart';

/// One check-up question as students can read it: `answer_index` is never
/// sent to the app, so there is no correct answer here.
class CheckupQuestion {
  const CheckupQuestion({
    required this.id,
    required this.level,
    required this.question,
    required this.options,
  });

  /// Null for rows that can't be shown: unknown level, blank text or fewer
  /// than two non-blank options.
  static CheckupQuestion? tryParse(Map<String, dynamic> row) {
    final id = row['id'];
    final level = row['level'];
    final question = row['question'];
    final options = row['options'];
    if (id is! int || id < 1) return null;
    if (level is! String || !UserProgress.cefrLevels.contains(level)) {
      return null;
    }
    if (question is! String || question.trim().isEmpty) return null;
    if (options is! List || options.length < 2) return null;
    // The server scores by position, so every option must stay in place.
    if (options.any((o) => o is! String || o.trim().isEmpty)) return null;

    return CheckupQuestion(
      id: id,
      level: level,
      question: question.trim(),
      options: List.unmodifiable(options.cast<String>().map((o) => o.trim())),
    );
  }

  final int id;
  final String level;
  final String question;
  final List<String> options;
}

/// One past check-up from `public.checkup_history`.
class CheckupHistoryEntry {
  const CheckupHistoryEntry({
    required this.cefrLevel,
    required this.score,
    required this.total,
    required this.takenAt,
  });

  static CheckupHistoryEntry? tryParse(Map<String, dynamic> row) {
    final level = row['cefr_level'];
    final score = row['score'];
    final total = row['total'];
    final takenAt = row['taken_at'];
    if (level is! String || !UserProgress.cefrLevels.contains(level)) {
      return null;
    }
    if (score is! int || total is! int || total <= 0) return null;
    final date = takenAt is String ? DateTime.tryParse(takenAt) : null;
    if (date == null) return null;
    return CheckupHistoryEntry(
      cefrLevel: level,
      score: score,
      total: total,
      takenAt: date,
    );
  }

  final String cefrLevel;
  final int score;
  final int total;
  final DateTime takenAt;
}

/// What `submit_checkup` returns: the new level and the raw score.
class CheckupResult {
  const CheckupResult({
    required this.cefrLevel,
    required this.score,
    required this.total,
    required this.takenAt,
  });

  factory CheckupResult.fromJson(Map<String, dynamic> json) {
    final entry = CheckupHistoryEntry.tryParse(json);
    if (entry == null) {
      throw FormatException('Unexpected submit_checkup result', json);
    }
    return CheckupResult(
      cefrLevel: entry.cefrLevel,
      score: entry.score,
      total: entry.total,
      takenAt: entry.takenAt,
    );
  }

  final String cefrLevel;
  final int score;
  final int total;
  final DateTime takenAt;
}
