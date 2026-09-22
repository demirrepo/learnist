import 'dart:convert';
import 'dart:io';

import 'package:learnist/models/checkup.dart';
import 'package:learnist/models/user_progress.dart';
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

/// In-memory stand-in for the three tables and `submit_checkup`.
///
/// A successful [submitCheckup] behaves like the server: it appends to
/// [history] and starts the cooldown in [progress], so a refetch after
/// submitting shows the cooldown state.
class FakeProgressService implements ProgressService {
  FakeProgressService({
    this.progress = const UserProgress(),
    List<CheckupHistoryEntry>? history,
    List<CheckupQuestion>? questions,
    this.nextResult,
  }) : history = [...?history],
       questions = questions ?? seedCheckupQuestions;

  UserProgress progress;
  final List<CheckupHistoryEntry> history;
  final List<CheckupQuestion> questions;

  /// What the next submission returns; defaults to B1, 18/30, now.
  CheckupResult? nextResult;

  Object? progressError;
  Object? historyError;
  Object? questionsError;
  Object? submitError;

  int progressFetches = 0;
  int questionFetches = 0;
  Map<int, int>? lastSubmitted;

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
}
