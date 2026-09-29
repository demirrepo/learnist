import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/lesson_model.dart';

Map<String, dynamic> _minimalRow() => {
  'lesson_number': 7,
  'original_number': 7,
  'semester': 1,
  'title': 'Made in the USA',
  'grammar_focus': 'Adjectives',
  'cefr_level': 'A1',
};

void main() {
  // The seed file has the same snake_case keys as the table's rows.
  group('seed data', () {
    final rows =
        (jsonDecode(File('lessons_seed_data.json').readAsStringSync()) as List)
            .cast<Map<String, dynamic>>();
    final lessons = rows.map(Lesson.fromJson).toList();

    test('all 52 rows parse, in order', () {
      expect(lessons, hasLength(52));
      expect(
        lessons.map((l) => l.lessonNumber),
        List.generate(52, (i) => i + 1),
      );
    });

    test('lesson 1 maps every column', () {
      final lesson = lessons.first;
      expect(lesson.title, 'Hello, everybody!');
      expect(lesson.grammarFocus, 'Subject pronouns + am / is / are');
      expect(lesson.cefrLevel, 'A1');
      expect(lesson.semester, 1);
      expect(lesson.topic, 'meeting new classmates');
      expect(lesson.taskMeta, hasLength(4));
      expect(lesson.grammarRules, startsWith('Tasavvur qiling'));
      expect(lesson.isFallbackGrammarRule, isFalse);
      expect(lesson.readingPassage, startsWith('Maya is taking part'));
      expect(lesson.readingVocabulary, hasLength(6));
      expect(lesson.readingQuestions, hasLength(10));
      expect(lesson.listeningSpeakers, ['Maya', 'Daniel']);
      expect(lesson.listeningTranscript, startsWith('Maya: Hi Daniel.'));
      expect(lesson.listeningQuestions, hasLength(10));
      expect(lesson.writingPrompt, startsWith('Write a short opinion'));
      expect(lesson.speakingPrompt, isNotNull);

      final question = lesson.readingQuestions.first as Map;
      expect(question['answer_index'], isA<int>());
      expect(question['options'], isA<List>());
    });

    test('lesson 38 is flagged as using the fallback guide', () {
      expect(lessons[37].isFallbackGrammarRule, isTrue);
      expect(lessons[37].grammarRules, isNotNull);
    });
  });

  test('missing optional columns become null or empty', () {
    final lesson = Lesson.fromJson(_minimalRow());
    expect(lesson.topic, isNull);
    expect(lesson.grammarRules, isNull);
    expect(lesson.readingPassage, isNull);
    expect(lesson.listeningTranscript, isNull);
    expect(lesson.audioUrl, isNull);
    expect(lesson.writingPrompt, isNull);
    expect(lesson.speakingPrompt, isNull);
    expect(lesson.taskMeta, isEmpty);
    expect(lesson.readingVocabulary, isEmpty);
    expect(lesson.readingQuestions, isEmpty);
    expect(lesson.listeningSpeakers, isEmpty);
    expect(lesson.listeningQuestions, isEmpty);
  });

  test('blank text is null; stray list items are dropped', () {
    final lesson = Lesson.fromJson({
      ..._minimalRow(),
      'topic': '   ',
      'reading_passage': '',
      'audio_url': '  ',
      'task_meta': ['Vocabulary', '', null, 3, ' Speaking '],
    });
    expect(lesson.topic, isNull);
    expect(lesson.readingPassage, isNull);
    // A blank audio_url must read as "no audio", not as an empty stream URL.
    expect(lesson.audioUrl, isNull);
    expect(lesson.taskMeta, ['Vocabulary', 'Speaking']);
  });

  test('audio_url is read from the row', () {
    const url =
        'https://xyz.supabase.co/storage/v1/object/public/'
        'listening_audios/lesson_07.mp3';
    final lesson = Lesson.fromJson({..._minimalRow(), 'audio_url': url});
    expect(lesson.audioUrl, url);
  });

  test('JSONB lists stored as strings are decoded; junk becomes empty', () {
    final lesson = Lesson.fromJson({
      ..._minimalRow(),
      'reading_questions': '[{"question": "Q?", "answer_index": 0}]',
      'listening_questions': 'not json',
      'reading_vocabulary': {'word': 'not a list'},
    });
    expect(lesson.readingQuestions, hasLength(1));
    expect(lesson.listeningQuestions, isEmpty);
    expect(lesson.readingVocabulary, isEmpty);
  });

  test('numeric columns accept 1.0 and "1"', () {
    final lesson = Lesson.fromJson({
      ..._minimalRow(),
      'lesson_number': 7.0,
      'semester': '2',
    });
    expect(lesson.lessonNumber, 7);
    expect(lesson.semester, 2);
  });

  test('missing required columns throw FormatException', () {
    expect(
      () => Lesson.fromJson(_minimalRow()..remove('title')),
      throwsFormatException,
    );
    expect(
      () => Lesson.fromJson({..._minimalRow(), 'lesson_number': 'seven'}),
      throwsFormatException,
    );
  });

  test('lists are read-only', () {
    final lesson = Lesson.fromJson({
      ..._minimalRow(),
      'task_meta': ['a'],
    });
    expect(() => lesson.taskMeta.add('b'), throwsUnsupportedError);
  });
}
