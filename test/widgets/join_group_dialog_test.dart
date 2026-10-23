import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnist/services/teacher_service.dart';
import 'package:learnist/widgets/join_group_dialog.dart';

import '../support/fake_teacher_service.dart';
import '../support/l10n.dart';

Future<void> _open(
  WidgetTester tester,
  FakeTeacherService teacher,
  Locale locale,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [teacherServiceProvider.overrideWithValue(teacher)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => showJoinGroupDialog(context),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester, String login, String password) async {
  await tester.enterText(find.byKey(const ValueKey('join-group-login')), login);
  await tester.enterText(
    find.byKey(const ValueKey('join-group-password')),
    password,
  );
  await tester.tap(find.byKey(const ValueKey('join-group-submit')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final lang in [
    (
      locale: const Locale('ru'),
      texts: [
        'Вступить в группу',
        'Введите логин и пароль класса, которые дал вам преподаватель.',
        'Логин класса',
        'Пароль',
        'Отмена',
        'Вступить',
      ],
      required: 'Заполните это поле.',
      wrong: 'Неверный логин или пароль.',
      joined: 'Вы вступили в группу «English group 301».',
    ),
    (
      locale: const Locale('en'),
      texts: [
        'Join a group',
        'Enter the class login and password your teacher gave you.',
        'Class login',
        'Password',
        'Cancel',
        'Join',
      ],
      required: 'Fill in this field.',
      wrong: 'Wrong login or password.',
      joined: 'You joined «English group 301».',
    ),
    (
      locale: const Locale('kk'),
      texts: [
        'Toparǵa qosılıw',
        'Oqıtıwshıńız bergen login hám paroldi kiritiń.',
        'Klass logini',
        'Parol',
        'Biykar etiw',
        'Qosılıw',
      ],
      required: 'Maydandı toltırıń.',
      wrong: 'Login yamasa parol qáte.',
      joined: '«English group 301» toparına qosıldıńız.',
    ),
  ]) {
    testWidgets('the dialog follows ${lang.locale.languageCode}', (
      tester,
    ) async {
      final teacher = FakeTeacherService(
        joinableGroups: {('ELT301', 'elt301'): 'English group 301'},
      );
      await _open(tester, teacher, lang.locale);

      for (final text in lang.texts) {
        expect(find.text(text), findsOneWidget, reason: text);
      }

      await tester.tap(find.byKey(const ValueKey('join-group-submit')));
      await tester.pumpAndSettle();
      expect(find.text(lang.required), findsNWidgets(2));

      await _submit(tester, 'ELT301', 'wrong');
      expect(find.text(lang.wrong), findsOneWidget);

      await _submit(tester, 'ELT301', 'elt301');
      expect(find.byType(JoinGroupDialog), findsNothing);
      expect(find.text(lang.joined), findsOneWidget);
    });
  }
}
