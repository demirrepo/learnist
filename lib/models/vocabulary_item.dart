/// One `{word, definition, phonetic, translations}` item of a lesson's
/// `reading_vocabulary` JSONB column.
class VocabularyItem {
  const VocabularyItem({
    required this.word,
    this.definition,
    this.phonetic,
    this.translations = const {},
  });

  /// Items in [raw] order; entries without a word are skipped and blank
  /// optional fields become null.
  static List<VocabularyItem> listFrom(List<dynamic> raw) => [
    for (final item in raw)
      if (item is Map)
        if (_text(item['word']) case final word?)
          VocabularyItem(
            word: word,
            definition: _text(item['definition']),
            phonetic: _text(item['phonetic']),
            translations: {
              if (item['translations'] case final Map translations)
                for (final MapEntry(:key, :value) in translations.entries)
                  if (key is String)
                    if (_text(value) case final text?) key: text,
            },
          ),
  ];

  final String word;

  /// English definition.
  final String? definition;

  /// General American IPA between slashes, e.g. `/ˈklæsmeɪt/`.
  final String? phonetic;

  /// The word in other interface languages, keyed by language code.
  final Map<String, String> translations;

  /// The word in [languageCode], or null for English and untranslated
  /// languages.
  String? translationFor(String languageCode) => translations[languageCode];
}

String? _text(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;
