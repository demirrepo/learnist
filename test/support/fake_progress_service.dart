import 'dart:convert';
import 'dart:io';

import 'package:learnist/models/checkup.dart';
import 'package:learnist/models/tracked_mistake.dart';
import 'package:flutter/foundation.dart';
import 'package:learnist/models/user_progress.dart';
import 'package:learnist/models/user_stats.dart';
import 'package:learnist/services/progress_service.dart';

/// The 30 seeded questions, as students receive them (no answers).
final seedCheckupQuestions = [
  for (final row
      in jsonDecode(
            File('assets/data/checkup_questions.json').readAsStringSync(),
          )
          as List)
    CheckupQuestion.tryParse(row as Map<String, dynamic>)!,
];

/// In-memory stand-in for the five tables, `submit_checkup`,
/// `save_section_score` and `complete_lesson`.
///
/// [completeLesson] does not check [sectionScores]; set [completeError] to
/// an [InsufficientScoreException] to simulate a low average.
///
/// A successful [submitCheckup] behaves like the server: it appends to
/// [history] and starts the cooldown in [progress], so a refetch after
/// submitting shows the cooldown state.
///
/// Like the real service, successful score, mistake and completion writes
/// notify listeners so [userStatsProvider] refetches [stats].
class FakeProgressService extends ChangeNotifier implements ProgressService {
  FakeProgressService({
    this.progress = const UserProgress(),
    this.stats = const UserStats(),
    List<CheckupHistoryEntry>? history,
    List<CheckupQuestion>? questions,
    List<({TrackedMistake mistake, bool resolved})>? mistakes,
    this.nextResult,
  }) : history = [...?history],
       mistakes = [...?mistakes],
       questions = questions ?? seedCheckupQuestions;

  UserProgress progress;
  UserStats stats;
  final List<CheckupHistoryEntry> history;
  final List<CheckupQuestion> questions;

  /// Every `user_mistakes` row, resolved or not.
  final List<({TrackedMistake mistake, bool resolved})> mistakes;

  /// What the next submission returns; defaults to B1, 18/30, now.
  CheckupResult? nextResult;

  Object? progressError;
  Object? historyError;
  Object? questionsError;
  Object? submitError;
  Object? completeError;
  Object? saveScoreError;
  Object? statsError;
  Object? saveMistakesError;
  Object? mistakesError;

  int progressFetches = 0;
  int questionFetches = 0;
  int statsFetches = 0;
  int mistakeFetches = 0;
  Map<int, int>? lastSubmitted;
  final List<int> completedLessons = [];

  /// Latest score per lesson and section, as `save_section_score` keeps it.
  final Map<int, Map<String, int>> sectionScores = {};

  /// Every `upsert_mistakes` call, in order.
  final List<({int lesson, String section, List<int> wrong})> mistakeCalls = [];

  @override
  Future<UserStats> fetchStats() async {
    statsFetches++;
    if (statsError case final error?) throw error;
    return stats;
  }

  @override
  Future<void> saveMistakes(
    int lessonNumber,
    String section,
    List<int> wrongQuestionIndexes,
  ) async {
    if (saveMistakesError case final error?) throw error;
    mistakeCalls.add((
      lesson: lessonNumber,
      section: section,
      wrong: List.of(wrongQuestionIndexes),
    ));
    notifyListeners();
  }

  /// Like the query: unresolved, at least twice, most frequent first.
  @override
  Future<List<TrackedMistake>> fetchRecurringMistakes() async {
    mistakeFetches++;
    if (mistakesError case final error?) throw error;
    return [
      for (final row in mistakes)
        if (!row.resolved &&
            row.mistake.frequency >= TrackedMistake.recurringThreshold)
          row.mistake,
    ]..sort((a, b) => b.frequency.compareTo(a.frequency));
  }

  @override
  Future<UserProgress> fetchProgress() async {
    progressFetches++;
    if (progressError case final error?) throw error;
    return progress;
  }

  @override
  Future<List<CheckupHistoryEntry>> fetchCheckupHistory() async {
    if (historyError case final error?) throw error;
    return List.of(history);
  }

  @override
  Future<List<CheckupQuestion>> fetchCheckupQuestions() async {
    questionFetches++;
    if (questionsError case final error?) throw error;
    return questions;
  }

  @override
  Future<CheckupResult> submitCheckup(Map<int, int> answers) async {
    lastSubmitted = answers;
    if (submitError case final error?) throw error;

    final result =
        nextResult ??
        CheckupResult(
          cefrLevel: 'B1',
          score: 18,
          total: questions.length,
          takenAt: DateTime.now(),
        );
    history.add(
      CheckupHistoryEntry(
        cefrLevel: result.cefrLevel,
        score: result.score,
        total: result.total,
        takenAt: result.takenAt,
      ),
    );
    progress = UserProgress(
      cefrLevel: result.cefrLevel,
      currentLesson: progress.currentLesson,
      lastCheckupDate: result.takenAt,
    );
    return result;
  }

  @override
  Future<void> saveSectionScore(
    int lessonNumber,
    String section,
    int score,
  ) async {
    if (saveScoreError case final error?) throw error;
    (sectionScores[lessonNumber] ??= {})[section] = score;
    notifyListeners();
  }

  /// Like the server: advances only from the current lesson, up to 52.
  @override
  Future<void> completeLesson(int lessonNumber) async {
    completedLessons.add(lessonNumber);
    if (completeError case final error?) throw error;
    if (progress.currentLesson == lessonNumber) {
      progress = UserProgress(
        cefrLevel: progress.cefrLevel,
        currentLesson: (lessonNumber + 1).clamp(1, UserProgress.lastLesson),
        lastCheckupDate: progress.lastCheckupDate,
      );
    }
    notifyListeners();
  }
}
