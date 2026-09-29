import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnist/providers/app_language_provider.dart';

void main() {
  ProviderContainer container() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
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

    expect(c.read(appLanguageProvider), 'ru');
    expect(seen, ['en', 'ru']);
  });

  test('unknown codes are ignored', () {
    final c = container();
    c.read(appLanguageProvider.notifier).select('en');

    c.read(appLanguageProvider.notifier).select('de');

    expect(c.read(appLanguageProvider), 'en');
  });

  test('every language has a label', () {
    expect(appLanguages.map((l) => l.$1), ['uz', 'en', 'ru']);
    expect(appLanguageLabel('ru'), 'Русский');
    expect(appLanguageLabel('xx'), "O'zbekcha");
  });
}
