import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/checkup.dart';

void main() {
  group('CheckupQuestion.tryParse', () {
    test('reads a row without an answer', () {
      final question = CheckupQuestion.tryParse({
        'id': 3,
        'level': 'A1',
        'question': ' ___ you like coffee? ',
        'options': ['Does', 'Do'],
      });
      expect(question?.id, 3);
      expect(question?.question, '___ you like coffee?');
      expect(question?.options, ['Does', 'Do']);
    });

    test('rejects rows that cannot be shown or scored by position', () {
      const good = {
        'id': 1,
        'level': 'A1',
        'question': 'Q',
        'options': ['a', 'b'],
      };
      final bad = <Map<String, dynamic>>[
        {...good, 'id': 0},
        {...good, 'id': '1'},
        {...good, 'level': 'B3'},
        {...good, 'question': '  '},
        {
          ...good,
          'options': ['a'],
        },
        {
          ...good,
          'options': ['a', ''],
        },
        {
          ...good,
          'options': ['a', 2],
        },
        {...good, 'options': 'a,b'},
      ];
      expect(CheckupQuestion.tryParse(good), isNotNull);
      for (final row in bad) {
        expect(CheckupQuestion.tryParse(row), isNull, reason: '$row');
      }
    });
  });

  group('CheckupHistoryEntry.tryParse', () {
    test('reads a history row', () {
      final entry = CheckupHistoryEntry.tryParse({
        'cefr_level': 'B2',
        'score': 21,
        'total': 30,
        'taken_at': '2026-09-20T08:30:00+00:00',
      });
      expect(entry?.cefrLevel, 'B2');
      expect(entry?.score, 21);
      expect(entry?.takenAt, DateTime.utc(2026, 9, 20, 8, 30));
    });

    test('skips malformed rows', () {
      const good = {
        'cefr_level': 'B2',
        'score': 21,
        'total': 30,
        'taken_at': '2026-09-20T08:30:00Z',
      };
      for (final row in <Map<String, dynamic>>[
        {...good, 'cefr_level': 'Z9'},
        {...good, 'score': '21'},
        {...good, 'total': 0},
        {...good, 'taken_at': 'yesterday'},
        {...good, 'taken_at': null},
      ]) {
        expect(CheckupHistoryEntry.tryParse(row), isNull, reason: '$row');
      }
    });
  });

  test('CheckupResult.fromJson reads the RPC result and rejects junk', () {
    final result = CheckupResult.fromJson({
      'cefr_level': 'B1',
      'score': 24,
      'total': 30,
      'taken_at': '2026-09-22T12:44:19.255072+05:00',
      'level_scores': {},
    });
    expect(result.cefrLevel, 'B1');
    expect(result.score, 24);
    expect(
      () => CheckupResult.fromJson({'cefr_level': 'B1'}),
      throwsFormatException,
    );
  });
}
