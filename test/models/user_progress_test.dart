import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/user_progress.dart';

void main() {
  group('UserProgress.fromJson', () {
    test('new accounts get safe defaults', () {
      for (final metadata in [null, <String, dynamic>{}]) {
        final progress = UserProgress.fromJson(metadata);
        expect(progress.cefrLevel, isNull);
        expect(progress.currentLesson, 1);
        expect(progress.lastCheckupDate, isNull);
      }
    });

    test('reads stored values', () {
      final progress = UserProgress.fromJson({
        'cefr_level': 'B2',
        'current_lesson': 14,
        'last_checkup_date': '2026-09-20T08:30:00Z',
      });
      expect(progress.cefrLevel, 'B2');
      expect(progress.currentLesson, 14);
      expect(progress.lastCheckupDate, DateTime.utc(2026, 9, 20, 8, 30));
    });

    test('normalises and rejects malformed values', () {
      expect(UserProgress.fromJson({'cefr_level': ' c1 '}).cefrLevel, 'C1');
      for (final bad in ['B3', '', 'native', 7, null]) {
        expect(
          UserProgress.fromJson({'cefr_level': bad}).cefrLevel,
          isNull,
          reason: '$bad',
        );
      }

      int lesson(Object? value) =>
          UserProgress.fromJson({'current_lesson': value}).currentLesson;
      expect(lesson('7'), 7);
      expect(lesson(7.0), 7);
      expect(lesson(0), 1);
      expect(lesson(99), 52);
      expect(lesson('seven'), 1);
      expect(lesson(2.5), 1);

      DateTime? date(Object? value) =>
          UserProgress.fromJson({'last_checkup_date': value}).lastCheckupDate;
      expect(date('yesterday'), isNull);
      expect(date(1726992000), isNull);
    });
  });

  group('CheckupAvailability.at', () {
    final now = DateTime(2026, 9, 22, 12);

    test('never taken is available for the first time', () {
      final result = CheckupAvailability.at(null, now);
      expect(result, isA<CheckupAvailable>());
      expect((result as CheckupAvailable).firstTime, isTrue);
    });

    test('exactly 10 days later is available again', () {
      final result = CheckupAvailability.at(
        now.subtract(const Duration(days: 10)),
        now,
      );
      expect(result, isA<CheckupAvailable>());
      expect((result as CheckupAvailable).firstTime, isFalse);
    });

    int daysLeft(Duration ago) {
      final result = CheckupAvailability.at(now.subtract(ago), now);
      return (result as CheckupOnCooldown).daysRemaining;
    }

    test('partial days round up', () {
      expect(daysLeft(Duration.zero), 10);
      expect(daysLeft(const Duration(days: 3)), 7);
      expect(daysLeft(const Duration(days: 3, hours: 5)), 7);
      expect(daysLeft(const Duration(days: 9, hours: 23)), 1);
    });

    test('a future date never shows more than the full cooldown', () {
      expect(daysLeft(const Duration(days: -4)), 10);
    });
  });
}
