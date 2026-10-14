import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages the app offers, as `(code, label)` in picker order.
const appLanguages = [
  ('uz', "O'zbekcha"),
  ('en', 'English'),
  ('ru', 'Русский'),
  ('kk', 'Qaraqalpaqsha'),
];

/// Where the picked language is saved.
const selectedLanguageKey = 'selected_language';

/// Preferences loaded before `runApp`, so saved settings apply on the first
/// frame. `main` overrides this; left null (as in most tests), choices are
/// kept in memory only.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// The picked app language code: the saved one, else 'uz'.
final appLanguageProvider = NotifierProvider<AppLanguage, String>(
  AppLanguage.new,
);

class AppLanguage extends Notifier<String> {
  @override
  String build() {
    final saved = ref
        .read(sharedPreferencesProvider)
        ?.getString(selectedLanguageKey);
    // A saved code the app no longer offers falls back to the default.
    return saved != null && _isOffered(saved) ? saved : 'uz';
  }

  /// Switches at once and saves the choice. Ignores codes not in
  /// [appLanguages].
  void select(String code) {
    if (!_isOffered(code)) return;
    state = code;
    ref.read(sharedPreferencesProvider)?.setString(selectedLanguageKey, code);
  }

  static bool _isOffered(String code) =>
      appLanguages.any((language) => language.$1 == code);
}

/// The picker label for [code], e.g. "O'zbekcha" for 'uz'.
String appLanguageLabel(String code) =>
    appLanguages
        .firstWhere((l) => l.$1 == code, orElse: () => appLanguages.first)
        .$2;
