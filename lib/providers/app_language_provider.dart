import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The languages the app offers, as `(code, label)` in picker order.
const appLanguages = [
  ('uz', "O'zbekcha"),
  ('en', 'English'),
  ('ru', 'Русский'),
];

/// The picked app language code, 'uz' by default.
///
/// UI only for now: strings are not translated until l10n lands, and the
/// choice is not saved across restarts.
final appLanguageProvider = NotifierProvider<AppLanguage, String>(
  AppLanguage.new,
);

class AppLanguage extends Notifier<String> {
  @override
  String build() => 'uz';

  /// Ignores codes not in [appLanguages].
  void select(String code) {
    if (appLanguages.any((language) => language.$1 == code)) state = code;
  }
}

/// The picker label for [code], e.g. "O'zbekcha" for 'uz'.
String appLanguageLabel(String code) =>
    appLanguages
        .firstWhere((l) => l.$1 == code, orElse: () => appLanguages.first)
        .$2;
