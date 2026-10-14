import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/providers/app_language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ProviderContainer container([SharedPreferences? preferences]) {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<SharedPreferences> preferences([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('defaults to Uzbek', () {
    final c = container();
    expect(c.read(appLanguageProvider), 'uz');
    expect(appLanguageLabel(c.read(appLanguageProvider)), "O'zbekcha");
  });

  test('select changes the language and notifies listeners', () {
    final c = container();
    final seen = <String>[];
    c.listen(appLanguageProvider, (_, next) => seen.add(next));

    c.read(appLanguageProvider.notifier).select('en');
    c.read(appLanguageProvider.notifier).select('ru');
    c.read(appLanguageProvider.notifier).select('kk');

    expect(c.read(appLanguageProvider), 'kk');
    expect(seen, ['en', 'ru', 'kk']);
  });

  test('unknown codes are ignored', () {
    final c = container();
    c.read(appLanguageProvider.notifier).select('en');

    c.read(appLanguageProvider.notifier).select('de');

    expect(c.read(appLanguageProvider), 'en');
  });

  test('every language has a label', () {
    expect(appLanguages.map((l) => l.$1), ['uz', 'en', 'ru', 'kk']);
    expect(appLanguageLabel('ru'), 'Русский');
    expect(appLanguageLabel('kk'), 'Qaraqalpaqsha');
    expect(appLanguageLabel('xx'), "O'zbekcha");
  });

  group('persistence', () {
    test('starts in the saved language', () async {
      final c = container(await preferences({selectedLanguageKey: 'kk'}));

      expect(c.read(appLanguageProvider), 'kk');
    });

    test('defaults to Uzbek when nothing is saved', () async {
      final c = container(await preferences());

      expect(c.read(appLanguageProvider), 'uz');
    });

    test('a saved code the app no longer offers falls back to Uzbek', () async {
      final c = container(await preferences({selectedLanguageKey: 'de'}));

      expect(c.read(appLanguageProvider), 'uz');
    });

    test('select saves the choice for the next launch', () async {
      final prefs = await preferences();
      container(prefs).read(appLanguageProvider.notifier).select('ru');

      expect(prefs.getString(selectedLanguageKey), 'ru');
      // A fresh container stands in for an app restart.
      expect(container(prefs).read(appLanguageProvider), 'ru');
    });

    test('unknown codes are not saved', () async {
      final prefs = await preferences({selectedLanguageKey: 'en'});
      container(prefs).read(appLanguageProvider.notifier).select('de');

      expect(prefs.getString(selectedLanguageKey), 'en');
    });
  });
}
