import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/models/vocabulary_item.dart';

import '../support/fake_lesson_service.dart';

void main() {
  test('parses word, IPA, definition and translations', () {
    final [item] = VocabularyItem.listFrom([
      {
        'word': ' classmate ',
        'phonetic': '/ˈklæsmeɪt/',
        'definition': 'a person who studies in the same class',
        'translations': {'uz': 'sinfdosh', 'ru': 'одноклассник', 'kk': ' '},
      },
    ]);

    expect(item.word, 'classmate');
    expect(item.phonetic, '/ˈklæsmeɪt/');
    expect(item.definition, 'a person who studies in the same class');
    expect(item.translationFor('ru'), 'одноклассник');
    expect(item.translationFor('kk'), isNull, reason: 'blank is untranslated');
    expect(item.translationFor('en'), isNull);
  });

  test('older rows without IPA or translations still parse', () {
    final items = VocabularyItem.listFrom([
      {'word': 'cloud', 'definition': 'online storage'},
      {'word': '  '},
      'not a map',
      {'word': 'tram', 'translations': 'not a map'},
    ]);

    expect(items.map((item) => item.word), ['cloud', 'tram']);
    expect(items.first.phonetic, isNull);
    expect(items.last.translations, isEmpty);
  });

  test('every seeded word has IPA and uz/ru/kk translations', () {
    for (final lesson in seedLessons) {
      final items = VocabularyItem.listFrom(lesson.readingVocabulary);
      expect(items, hasLength(lesson.readingVocabulary.length));
      for (final item in items) {
        final where = 'lesson ${lesson.lessonNumber}: ${item.word}';
        expect(item.phonetic, matches(RegExp(r'^/.+/$')), reason: where);
        expect(
          item.translations.keys,
          unorderedEquals(['uz', 'ru', 'kk']),
          reason: where,
        );
      }
    }
  });
}
