import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:learnist/main.dart';
import 'package:learnist/screens/ai_lab_screen.dart';
import 'package:learnist/screens/auth_screen.dart';
import 'package:learnist/screens/edit_profile_screen.dart';
import 'package:learnist/screens/error_map_screen.dart';
import 'package:learnist/screens/home_screen.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/screens/profile_screen.dart';
import 'package:learnist/screens/update_password_screen.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:learnist/widgets/error_map/error_pattern_card.dart';
import 'package:learnist/widgets/main_layout.dart';

/// In-memory auth so tests never touch Supabase.
class _FakeSupabaseService extends ChangeNotifier implements SupabaseService {
  _FakeSupabaseService({
    required bool signedIn,
    this.takenUsernames = const {},
    this.fullName,
    this.username,
    this.university,
  }) : _signedIn = signedIn;

  bool _signedIn;
  String? fullName;
  String? username;
  String? university;
  Object? updateProfileError;
  Map<String, String>? lastProfileUpdate;
  bool _recovering = false;
  final Set<String> takenUsernames;
  final _linkErrors = StreamController<AuthException>.broadcast();
  Map<String, String>? lastSignUp;
  String? lastResetEmail;
  String? lastNewPassword;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get currentUserFullName => fullName;

  @override
  String? get currentUsername => username;

  @override
  String? get currentUserUniversity => university;

  @override
  bool get isRecoveringPassword => _recovering;

  @override
  Stream<AuthException> get authLinkErrors => _linkErrors.stream;

  /// What supabase_flutter does after a valid reset link is opened.
  void simulatePasswordRecovery() {
    _signedIn = true;
    _recovering = true;
    notifyListeners();
  }

  void emitLinkError(AuthException error) => _linkErrors.add(error);

  @override
  Future<void> signIn({required String email, required String password}) async {
    _signedIn = true;
    notifyListeners();
  }

  @override
  Future<bool> isUsernameTaken(String username) async =>
      takenUsernames.contains(username);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String university,
  }) async {
    lastSignUp = {
      'full_name': fullName,
      'username': username,
      'university': university,
    };
    return AuthResponse();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    lastResetEmail = email;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    lastNewPassword = newPassword;
    _recovering = false;
    notifyListeners();
  }

  @override
  Future<void> cancelPasswordRecovery() async {
    _recovering = false;
    await signOut();
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String university,
  }) async {
    final error = updateProfileError;
    if (error != null) throw error;
    lastProfileUpdate = {
      'full_name': fullName,
      'username': username,
      'university': university,
    };
    this.fullName = fullName;
    this.username = username;
    this.university = university;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _linkErrors.close();
    super.dispose();
  }
}

Widget _app(_FakeSupabaseService auth) => ProviderScope(
      overrides: [supabaseServiceProvider.overrideWithValue(auth)],
      child: const LearnistApp(),
    );

Finder _byKey(String key) => find.byKey(ValueKey(key));

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _selectUniversity(
  WidgetTester tester,
  String query,
  String university,
) async {
  await _tapVisible(tester, _byKey('auth-university'));
  await tester.enterText(_byKey('auth-university'), query);
  await tester.pumpAndSettle();
  await tester.tap(find.text(university).last);
  await tester.pumpAndSettle();
}

Future<void> _fillCommonSignUpFields(
  WidgetTester tester, {
  required String username,
}) async {
  await tester.enterText(_byKey('auth-full-name'), 'Test Student');
  await tester.enterText(_byKey('auth-username'), username);
  await tester.enterText(_byKey('auth-email'), 'a@b.uz');
  await tester.enterText(_byKey('auth-password'), 'secret123');
}

void main() {
  // Tests have no network; skip fetching Google Fonts.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('signed-out users are sent to /auth, then /home after sign in',
      (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsNothing);

    await tester.enterText(_byKey('auth-email'), 'a@b.uz');
    await tester.enterText(_byKey('auth-password'), 'secret123');
    await _tapVisible(tester, _byKey('auth-submit'));

    expect(find.byType(AuthScreen), findsNothing);
    expect(find.byType(LearnistNavBar), findsOneWidget);

    await auth.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('sign up sends profile fields, including other university',
      (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(_byKey('auth-other-university'), findsNothing);

    await _selectUniversity(tester, 'Boshqa', 'Boshqa / Other');
    expect(_byKey('auth-other-university'), findsOneWidget);

    await _fillCommonSignUpFields(tester, username: 'Learner_01');
    await tester.enterText(_byKey('auth-other-university'), 'My College');
    await _tapVisible(tester, _byKey('auth-submit'));

    expect(auth.lastSignUp, {
      'full_name': 'Test Student',
      'username': 'learner_01',
      'university': 'My College',
    });
    // No session returned → confirmation SnackBar, back to Sign In mode.
    expect(find.textContaining('Tasdiqlash havolasi'), findsOneWidget);
    expect(_byKey('auth-full-name'), findsNothing);
  });

  testWidgets('taken username stops sign-up before calling signUp',
      (tester) async {
    final auth = _FakeSupabaseService(
      signedIn: false,
      takenUsernames: {'learner_01'},
    );
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await _selectUniversity(tester, 'Inha', 'Inha University in Tashkent');
    await _fillCommonSignUpFields(tester, username: 'Learner_01');
    await _tapVisible(tester, _byKey('auth-submit'));

    expect(find.text(usernameTakenMessage), findsOneWidget);
    expect(auth.lastSignUp, isNull);
    // Still on the sign-up form so the user can pick another name.
    expect(_byKey('auth-full-name'), findsOneWidget);
  });

  testWidgets('footer link switches modes; forgot link is sign-in only',
      (tester) async {
    await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: false)));
    await tester.pumpAndSettle();
    expect(_byKey('auth-forgot-password'), findsOneWidget);

    await _tapVisible(tester, find.text('Create an account'));
    expect(_byKey('auth-full-name'), findsOneWidget);
    expect(_byKey('auth-forgot-password'), findsNothing);

    await _tapVisible(tester, find.text('Sign in instead'));
    expect(_byKey('auth-full-name'), findsNothing);
    expect(_byKey('auth-forgot-password'), findsOneWidget);
  });

  testWidgets('forgot password sheet sends the reset email', (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    await tester.enterText(_byKey('auth-email'), 'a@b.uz');
    await _tapVisible(tester, _byKey('auth-forgot-password'));

    expect(find.text('Parolni tiklash'), findsOneWidget);
    // Prefilled from the sign-in form.
    expect(
      tester.widget<TextFormField>(_byKey('forgot-email')).controller!.text,
      'a@b.uz',
    );

    await _tapVisible(tester, _byKey('forgot-submit'));

    expect(auth.lastResetEmail, 'a@b.uz');
    expect(_byKey('forgot-email'), findsNothing);
    expect(find.text(passwordResetSentMessage), findsOneWidget);
  });

  testWidgets('recovery event opens update screen; saving returns home',
      (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    auth.simulatePasswordRecovery();
    await tester.pumpAndSettle();
    expect(find.byType(UpdatePasswordScreen), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsNothing);

    await tester.enterText(_byKey('update-password-field'), '123');
    await _tapVisible(tester, _byKey('update-password-submit'));
    expect(find.text("Parol kamida 6 ta belgidan iborat bo'lsin"), findsOneWidget);
    expect(auth.lastNewPassword, isNull);

    await tester.enterText(_byKey('update-password-field'), 'newSecret1');
    await _tapVisible(tester, _byKey('update-password-submit'));

    expect(auth.lastNewPassword, 'newSecret1');
    expect(find.byType(UpdatePasswordScreen), findsNothing);
    expect(find.byType(LearnistNavBar), findsOneWidget);
    expect(find.text(passwordUpdatedMessage), findsOneWidget);
  });

  testWidgets('cancelling recovery signs out to the auth screen',
      (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    auth.simulatePasswordRecovery();
    await tester.pumpAndSettle();
    await _tapVisible(tester, _byKey('update-password-cancel'));

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(auth.isSignedIn, isFalse);
  });

  testWidgets('expired reset link shows an Uzbek message', (tester) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    // Shape produced by gotrue for learnist://reset?error=access_denied&error_code=otp_expired
    auth.emitLinkError(
      AuthException(
        'Email link is invalid or has expired',
        statusCode: 'otp_expired',
        code: 'access_denied',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Havola eskirgan'), findsOneWidget);
  });

  testWidgets('bottom navigation switches tabs', (tester) async {
    await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: true)));
    await tester.pumpAndSettle();

    expect(find.text('Your snapshot'), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsOneWidget);

    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('52-lesson pathway'), findsOneWidget);

    // Lessons open inside the shell, so the nav bar stays visible.
    await tester.tap(find.text('Lesson 1. Hello, everybody!'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson 1: Hello, everybody!'), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('52-lesson pathway'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Tizimdan chiqish'), findsOneWidget);
  });

  group('profile screen', () {
    Future<void> openProfile(
      WidgetTester tester,
      _FakeSupabaseService auth,
    ) async {
      await tester.pumpWidget(_app(auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows name, username and university from metadata',
        (tester) async {
      await openProfile(
        tester,
        _FakeSupabaseService(
          signedIn: true,
          fullName: 'Demirbek Razzaqov',
          username: 'redscorpnoir',
          university: 'Westminster International University in Tashkent',
        ),
      );

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('DR'), findsOneWidget);
      expect(find.text('Demirbek Razzaqov'), findsOneWidget);
      expect(find.text('@redscorpnoir'), findsOneWidget);
      expect(
        find.text('Westminster International University in Tashkent'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back when metadata is missing', (tester) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(find.text('Foydalanuvchi'), findsOneWidget);
      expect(find.text('Talaba'), findsOneWidget);
      expect(find.textContaining('@'), findsNothing);
    });

    testWidgets('sign out returns to the auth screen', (tester) async {
      final auth = _FakeSupabaseService(signedIn: true, fullName: 'A B');
      await openProfile(tester, auth);

      await _tapVisible(tester, find.text('Tizimdan chiqish'));

      expect(auth.isSignedIn, isFalse);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(LearnistNavBar), findsNothing);
    });

    testWidgets('language sheet updates the selection and closes',
        (tester) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(find.text("O'zbekcha"), findsOneWidget);
      await _tapVisible(tester, find.text('Til'));

      expect(find.text('Tilni tanlang'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text("O'zbekcha"), findsNWidgets(2));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Tilni tanlang'), findsNothing);
      expect(find.text('English'), findsOneWidget);
      expect(find.text("O'zbekcha"), findsNothing);
      expect(find.byType(LearnistNavBar), findsOneWidget);
    });

    testWidgets('error map is a menu item, not embedded in the profile',
        (tester) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(find.text('Xatolar xaritasi'), findsOneWidget);
      expect(find.byType(ErrorPatternCard), findsNothing);
      expect(find.byIcon(Icons.troubleshoot), findsOneWidget);
    });

    testWidgets('error map lists recurring patterns and opens the lesson',
        (tester) async {
      // Tall view so the lazy ListView builds every card.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await openProfile(tester, _FakeSupabaseService(signedIn: true));
      await _tapVisible(tester, find.text('Xatolar xaritasi'));

      expect(find.byType(ErrorMapScreen), findsOneWidget);
      expect(find.byType(LearnistNavBar), findsNothing);
      expect(find.byType(ErrorPatternCard), findsNWidgets(3));
      expect(find.text('Subject pronouns: am / is / are'), findsOneWidget);
      expect(
        find.text("So'nggi testlarda 4 marta xato qilingan"),
        findsOneWidget,
      );
      // A one-off mistake is not a pattern.
      expect(find.text('Articles: a / an'), findsNothing);

      await _tapVisible(tester, find.text('Subject pronouns: am / is / are'));
      expect(find.byType(LessonDetailScreen), findsOneWidget);

      // Back returns to the map, not to a tab.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorMapScreen), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    test('only recurring patterns are kept, most frequent first', () {
      ErrorPattern pattern(String rule, int count) => ErrorPattern(
            rule: rule,
            example: '',
            correction: '',
            mistakeCount: count,
            lessonLabel: '',
          );

      final result = recurringPatterns([
        pattern('once', 1),
        pattern('twice', 2),
        pattern('often', 5),
      ]);

      expect(result.map((p) => p.rule), ['often', 'twice']);
      expect(result.first.severity, ErrorSeverity.high);
      expect(result.last.severity, ErrorSeverity.medium);
      expect(pattern('edge', 4).severity, ErrorSeverity.high);
      expect(pattern('edge', 3).severity, ErrorSeverity.medium);
    });

    Future<void> openEditProfile(
      WidgetTester tester,
      _FakeSupabaseService auth,
    ) async {
      await openProfile(tester, auth);
      await _tapVisible(tester, find.text('Tahrirlash'));
      expect(find.byType(EditProfileScreen), findsOneWidget);
    }

    _FakeSupabaseService editableUser({Set<String> taken = const {}}) =>
        _FakeSupabaseService(
          signedIn: true,
          takenUsernames: taken,
          fullName: 'Aziz Karimov',
          username: 'aziz',
          university: 'Westminster International University in Tashkent',
        );

    FilledButton saveButton(WidgetTester tester) =>
        tester.widget<FilledButton>(_byKey('edit-save'));

    testWidgets('edit form is pre-filled and saving needs a change',
        (tester) async {
      await openEditProfile(tester, editableUser());

      expect(find.text('Profilni tahrirlash'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Aziz Karimov'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'aziz'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(_byKey('edit-full-name'), 'Aziz K.');
      await tester.pump();
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('empty metadata shows placeholder hints, not values',
        (tester) async {
      await openEditProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(find.text('Demir'), findsOneWidget);
      expect(find.text('demir_dev'), findsOneWidget);
      expect(find.text('Millat Umidi University'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: _byKey('edit-username'),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        isEmpty,
      );
    });

    testWidgets('a taken username blocks the save', (tester) async {
      final auth = editableUser(taken: {'taken_name'});
      await openEditProfile(tester, auth);

      await tester.enterText(_byKey('edit-username'), 'Taken_Name');
      await _tapVisible(tester, _byKey('edit-save'));

      expect(find.text(profileUsernameTakenMessage), findsOneWidget);
      expect(auth.lastProfileUpdate, isNull);
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    testWidgets('an unchanged username skips the availability check',
        (tester) async {
      // "aziz" is reported taken — by this same user.
      final auth = editableUser(taken: {'aziz'});
      await openEditProfile(tester, auth);

      await tester.enterText(_byKey('edit-full-name'), 'Aziz Karimov Jr');
      await _tapVisible(tester, _byKey('edit-save'));

      expect(auth.lastProfileUpdate?['username'], 'aziz');
    });

    testWidgets('saving updates the profile and returns to it',
        (tester) async {
      final auth = editableUser();
      await openEditProfile(tester, auth);

      await tester.enterText(_byKey('edit-full-name'), '  Aziz Karimov Jr ');
      await tester.enterText(_byKey('edit-username'), 'Aziz_K');
      await tester.enterText(_byKey('edit-university'), 'My College');
      await _tapVisible(tester, _byKey('edit-save'));

      expect(auth.lastProfileUpdate, {
        'full_name': 'Aziz Karimov Jr',
        'username': 'aziz_k',
        'university': 'My College',
      });
      expect(find.text(profileSavedMessage), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('@aziz_k'), findsOneWidget);
      expect(find.text('My College'), findsOneWidget);
    });

    testWidgets('save failures stay on the form with an Uzbek message',
        (tester) async {
      final auth = editableUser()
        ..updateProfileError = const PostgrestException(
          message: 'duplicate key value violates unique constraint',
          code: '23505',
        );
      await openEditProfile(tester, auth);

      await tester.enterText(_byKey('edit-username'), 'aziz_new');
      await _tapVisible(tester, _byKey('edit-save'));
      expect(find.text(profileUsernameTakenMessage), findsOneWidget);

      auth.updateProfileError = ClientException('offline');
      await tester.enterText(_byKey('edit-full-name'), 'Aziz Karimov II');
      await _tapVisible(tester, _byKey('edit-save'));
      expect(find.textContaining("Internet aloqasi yo'q"), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });

    test('profile errors map to Uzbek messages', () {
      expect(
        profileUpdateErrorMessage(const ProfileNotFoundException()),
        contains('Profilingiz topilmadi'),
      );
      expect(
        profileUpdateErrorMessage(
          const PostgrestException(message: 'denied', code: '42501'),
        ),
        contains('ruxsat'),
      );
    });

    test('initials use the first letters of up to two words', () {
      expect(initialsFrom('demirbek razzaqov ogli'), 'DR');
      expect(initialsFrom('  Aziz '), 'A');
      expect(initialsFrom('   '), isNull);
      expect(initialsFrom(null), isNull);
    });
  });

  group('home screen', () {
    testWidgets('greets the user by first name and renders all sections',
        (tester) async {
      await tester.pumpWidget(
        _app(
          _FakeSupabaseService(signedIn: true, fullName: 'Demirbek Razzaqov'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(', Demirbek 👋'), findsOneWidget);
      expect(find.text("TODAY'S FOCUS"), findsOneWidget);
      expect(find.text('Continue Lesson 2'), findsOneWidget);
      expect(find.text('Learning space'), findsOneWidget);
      expect(find.text('1/52'), findsOneWidget);
      expect(find.text('Lesson 1 · Present Simple'), findsOneWidget);
    });

    testWidgets('falls back to "Demir" without a full name', (tester) async {
      await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: true)));
      await tester.pumpAndSettle();

      expect(find.textContaining(', Demir 👋'), findsOneWidget);
    });

    testWidgets('Open AI Lab switches to the AI Lab tab', (tester) async {
      await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: true)));
      await tester.pumpAndSettle();

      await _tapVisible(tester, _byKey('home-open-ai-lab'));
      expect(find.byType(AiLabScreen), findsOneWidget);
    });

    test('greeting follows the time of day', () {
      expect(greetingFor(DateTime(2026, 9, 14, 8)), 'Good morning');
      expect(greetingFor(DateTime(2026, 9, 14, 14)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 9, 14, 23)), 'Good evening');
      expect(greetingFor(DateTime(2026, 9, 14, 2)), 'Good evening');
    });

    test('first name is taken from full_name', () {
      expect(firstNameFrom('  Demirbek   Razzaqov '), 'Demirbek');
      expect(firstNameFrom(''), 'Demir');
      expect(firstNameFrom(null), 'Demir');
    });
  });

  group('authErrorMessage', () {
    const internet = "Internet aloqasi yo'q";

    test('shows the internet message only for real connectivity failures', () {
      expect(
        authErrorMessage(
          AuthRetryableFetchException(message: 'Failed host lookup'),
        ),
        contains(internet),
      );
      expect(
        authErrorMessage(ClientException('Connection refused')),
        contains(internet),
      );
      expect(authErrorMessage(TimeoutException('slow')), contains(internet));
    });

    test('trigger failure (HTTP 500) means the username is taken', () {
      final error = AuthRetryableFetchException(
        message: '{"code":500,"error_code":"unexpected_failure",'
            '"msg":"Database error saving new user"}',
        statusCode: '500',
      );
      expect(authErrorMessage(error), usernameTakenMessage);
    });

    test('server and database errors are not reported as network errors', () {
      expect(
        authErrorMessage(
          AuthRetryableFetchException(message: 'Bad gateway', statusCode: '502'),
        ),
        allOf(isNot(contains(internet)), contains('Serverda')),
      );
      expect(
        authErrorMessage(const PostgrestException(message: 'boom')),
        isNot(contains(internet)),
      );
      expect(
        authErrorMessage(
          AuthApiException(
            'Invalid login credentials',
            statusCode: '400',
            code: 'invalid_credentials',
          ),
        ),
        "Email yoki parol noto'g'ri.",
      );
    });

    test('password reset errors', () {
      expect(
        authErrorMessage(
          AuthApiException(
            'New password should be different from the old password.',
            statusCode: '422',
            code: 'same_password',
          ),
        ),
        contains('eskisidan farq'),
      );
      expect(
        authErrorMessage(AuthPKCEGrantCodeExchangeError('no verifier')),
        contains("so'ragan qurilmada"),
      );
    });
  });
}
