import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:learnist/main.dart';
import 'package:learnist/models/teacher_dashboard.dart';
import 'package:learnist/models/tracked_mistake.dart';
import 'package:learnist/models/user_progress.dart';
import 'package:learnist/models/user_stats.dart';
import 'package:learnist/providers/app_language_provider.dart';
import 'package:learnist/screens/ai_lab_screen.dart';
import 'package:learnist/screens/auth_screen.dart';
import 'package:learnist/screens/edit_profile_screen.dart';
import 'package:learnist/screens/error_map_screen.dart';
import 'package:learnist/screens/home_screen.dart';
import 'package:learnist/screens/lesson_detail_screen.dart';
import 'package:learnist/screens/profile_screen.dart';
import 'package:learnist/screens/teacher_panel_screen.dart';
import 'package:learnist/screens/topics_screen.dart';
import 'package:learnist/screens/update_password_screen.dart';
import 'package:learnist/services/lesson_service.dart';
import 'package:learnist/services/progress_service.dart';
import 'package:learnist/services/supabase_service.dart';
import 'package:learnist/services/teacher_service.dart';
import 'package:learnist/theme/app_theme.dart';
import 'package:learnist/widgets/error_map/error_pattern_card.dart';
import 'package:learnist/widgets/home/lesson_mastery_progress.dart';
import 'package:learnist/widgets/join_group_dialog.dart';
import 'package:learnist/widgets/lesson/speaking_tab.dart';
import 'package:learnist/widgets/main_layout.dart';
import 'package:learnist/widgets/teacher/student_detail_dialog.dart';
import 'package:learnist/widgets/topics/topic_card.dart';

import 'support/fake_lesson_service.dart';
import 'support/fake_progress_service.dart';
import 'support/fake_teacher_service.dart';

/// In-memory auth so tests never touch Supabase.
class _FakeSupabaseService extends ChangeNotifier implements SupabaseService {
  _FakeSupabaseService({
    required bool signedIn,
    this.takenUsernames = const {},
    this.fullName,
    this.username,
    this.university,
    this.role = UserRole.student,
  }) : _signedIn = signedIn;

  UserRole role;

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
  UserRole get currentUserRole => role;

  @override
  bool get isTeacher => role == UserRole.teacher;

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

  /// The tab picked on the last sign-in.
  UserRole? lastSignInRole;

  /// Like the real service: refuses an account saved as the other [role].
  @override
  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    lastSignInRole = role;
    if (role != this.role) throw RoleMismatchException(this.role);
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
    required UserRole role,
  }) async {
    lastSignUp = {
      'full_name': fullName,
      'username': username,
      'university': university,
      'role': role.name,
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

Widget _app(
  _FakeSupabaseService auth, {
  FakeLessonService? lessons,
  FakeProgressService? progress,
  FakeTeacherService? teacher,
}) => ProviderScope(
  overrides: [
    supabaseServiceProvider.overrideWithValue(auth),
    lessonServiceProvider.overrideWithValue(lessons ?? FakeLessonService()),
    progressServiceProvider.overrideWithValue(
      progress ?? FakeProgressService(),
    ),
    teacherServiceProvider.overrideWithValue(teacher ?? FakeTeacherService()),
  ],
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

  testWidgets('signed-out users are sent to /auth, then /home after sign in', (
    tester,
  ) async {
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

  group('sign-in role check', () {
    Future<void> signInAs(WidgetTester tester, UserRole tab) async {
      await tester.tap(_byKey('auth-role-${tab.name}'));
      await tester.pump();
      await tester.enterText(_byKey('auth-email'), 'a@b.uz');
      await tester.enterText(_byKey('auth-password'), 'secret123');
      await _tapVisible(tester, _byKey('auth-submit'));
    }

    for (final (saved, picked, message) in [
      (
        UserRole.student,
        UserRole.teacher,
        "Siz talaba sifatida ro'yxatdan o'tgansiz. "
            "Iltimos, 'Talaba' bo'limini tanlang.",
      ),
      (
        UserRole.teacher,
        UserRole.student,
        "Siz o'qituvchi sifatida ro'yxatdan o'tgansiz. "
            "Iltimos, 'O'qituvchi' bo'limini tanlang.",
      ),
    ]) {
      testWidgets('a ${saved.name} on the ${picked.name} tab is refused', (
        tester,
      ) async {
        final auth = _FakeSupabaseService(signedIn: false, role: saved);
        await tester.pumpWidget(_app(auth));
        await tester.pumpAndSettle();

        await signInAs(tester, picked);

        expect(auth.lastSignInRole, picked);
        expect(auth.isSignedIn, isFalse);
        expect(find.byType(AuthScreen), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(
          tester
              .widget<SnackBar>(
                find.ancestor(
                  of: find.text(message),
                  matching: find.byType(SnackBar),
                ),
              )
              .backgroundColor,
          AppColors.danger,
        );
      });
    }

    testWidgets('a teacher on the teacher tab signs in', (tester) async {
      final auth = _FakeSupabaseService(
        signedIn: false,
        role: UserRole.teacher,
      );
      await tester.pumpWidget(_app(auth));
      await tester.pumpAndSettle();

      await signInAs(tester, UserRole.teacher);

      expect(auth.isSignedIn, isTrue);
      expect(find.byType(AuthScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  testWidgets('the active role pill is as tall as the active mode pill', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: false)));
    await tester.pumpAndSettle();

    Size pill(Finder label) => tester.getSize(
      find.ancestor(of: label, matching: find.byType(AnimatedContainer)).first,
    );
    final role = pill(find.text('Talaba'));
    final mode = pill(find.text('Sign In').first);
    expect(role.height, mode.height);
  });

  testWidgets('sign up sends profile fields, including other university', (
    tester,
  ) async {
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
      'role': 'student',
    });
    // No session returned → confirmation SnackBar, back to Sign In mode.
    expect(find.textContaining('Tasdiqlash havolasi'), findsOneWidget);
    expect(_byKey('auth-full-name'), findsNothing);
  });

  testWidgets('taken username stops sign-up before calling signUp', (
    tester,
  ) async {
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

  testWidgets('footer link switches modes; forgot link is sign-in only', (
    tester,
  ) async {
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

  testWidgets('recovery event opens update screen; saving returns home', (
    tester,
  ) async {
    final auth = _FakeSupabaseService(signedIn: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();

    auth.simulatePasswordRecovery();
    await tester.pumpAndSettle();
    expect(find.byType(UpdatePasswordScreen), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsNothing);

    await tester.enterText(_byKey('update-password-field'), '123');
    await _tapVisible(tester, _byKey('update-password-submit'));
    expect(
      find.text("Parol kamida 6 ta belgidan iborat bo'lsin"),
      findsOneWidget,
    );
    expect(auth.lastNewPassword, isNull);

    await tester.enterText(_byKey('update-password-field'), 'newSecret1');
    await _tapVisible(tester, _byKey('update-password-submit'));

    expect(auth.lastNewPassword, 'newSecret1');
    expect(find.byType(UpdatePasswordScreen), findsNothing);
    expect(find.byType(LearnistNavBar), findsOneWidget);
    expect(find.text(passwordUpdatedMessage), findsOneWidget);
  });

  testWidgets('cancelling recovery signs out to the auth screen', (
    tester,
  ) async {
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

    // Lessons are pushed full-screen above the tab shell.
    await tester.tap(find.text('1. Hello, everybody!'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonDetailScreen), findsOneWidget);
    expect(find.byType(LearnistNavBar), findsNothing);

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
      _FakeSupabaseService auth, {
      FakeProgressService? progress,
    }) async {
      await tester.pumpWidget(_app(auth, progress: progress));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows name, username and university from metadata', (
      tester,
    ) async {
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
      // Edit, error map, join group and language.
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('stats show lessons mastered and the overall average', (
      tester,
    ) async {
      final progress = FakeProgressService(
        stats: const UserStats(lessonsMastered: 6, overallAverage: 91),
      );
      await openProfile(
        tester,
        _FakeSupabaseService(signedIn: true),
        progress: progress,
      );

      expect(
        find.bySemanticsLabel("O'rganilgan mavzular: 6/52"),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel("O'rtacha natija: 91%"), findsOneWidget);

      progress.stats = const UserStats(lessonsMastered: 7, overallAverage: 89);
      await progress.completeLesson(7);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel("O'rganilgan mavzular: 7/52"),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel("O'rtacha natija: 89%"), findsOneWidget);
    });

    testWidgets('stats read zero before anything is scored', (tester) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(
        find.bySemanticsLabel("O'rganilgan mavzular: 0/52"),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel("O'rtacha natija: 0%"), findsOneWidget);
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

    testWidgets('language sheet updates the selection and closes', (
      tester,
    ) async {
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

      // Reopened, the check follows the provider.
      await _tapVisible(tester, find.text('Til'));
      final checked = find.ancestor(
        of: find.byIcon(Icons.check_circle),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: checked, matching: find.text('English')),
        findsOneWidget,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileScreen)),
      );
      expect(container.read(appLanguageProvider), 'en');
    });

    group('join group', () {
      Future<FakeTeacherService> openJoinDialog(WidgetTester tester) async {
        final teacher = FakeTeacherService(
          joinableGroups: {('ELT301', 'elt301'): 'English group 301'},
        );
        await tester.pumpWidget(
          _app(_FakeSupabaseService(signedIn: true), teacher: teacher),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        await _tapVisible(tester, find.text("Guruhga qo'shilish"));
        expect(find.byType(JoinGroupDialog), findsOneWidget);
        return teacher;
      }

      Future<void> submit(
        WidgetTester tester,
        String login,
        String password,
      ) async {
        await tester.enterText(_byKey('join-group-login'), login);
        await tester.enterText(_byKey('join-group-password'), password);
        await tester.tap(_byKey('join-group-submit'));
        await tester.pumpAndSettle();
      }

      testWidgets('valid credentials join and show a snackbar', (tester) async {
        await openJoinDialog(tester);
        expect(find.text('Class login'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);

        // Logins are case-insensitive.
        await submit(tester, 'elt301', 'elt301');

        expect(find.byType(JoinGroupDialog), findsNothing);
        expect(
          find.text("«English group 301» guruhiga qo'shildingiz."),
          findsOneWidget,
        );

        await _tapVisible(tester, find.text("Guruhga qo'shilish"));
        await submit(tester, 'ELT301', 'elt301');
        expect(
          find.text('Siz allaqachon «English group 301» guruhidasiz.'),
          findsOneWidget,
        );
      });

      testWidgets('a wrong password keeps the dialog open in Uzbek', (
        tester,
      ) async {
        await openJoinDialog(tester);

        await submit(tester, 'ELT301', 'wrong');

        expect(find.byType(JoinGroupDialog), findsOneWidget);
        expect(find.text("Login yoki parol noto'g'ri."), findsOneWidget);

        // The fields are kept, so fixing the password is enough.
        await tester.enterText(_byKey('join-group-password'), 'elt301');
        await tester.tap(_byKey('join-group-submit'));
        await tester.pumpAndSettle();
        expect(find.byType(JoinGroupDialog), findsNothing);
      });

      testWidgets('empty fields are caught before any request', (tester) async {
        final teacher = await openJoinDialog(tester);
        teacher.joinError = StateError('must not be called');

        await tester.tap(_byKey('join-group-submit'));
        await tester.pumpAndSettle();

        expect(find.text("Maydonni to'ldiring."), findsNWidgets(2));
        expect(find.byType(JoinGroupDialog), findsOneWidget);
      });

      testWidgets('a network failure says so', (tester) async {
        final teacher = await openJoinDialog(tester);
        teacher.joinError = ClientException('offline');

        await submit(tester, 'ELT301', 'elt301');

        expect(find.textContaining("Internet aloqasi yo'q"), findsOneWidget);
      });

      testWidgets('cancel closes without joining', (tester) async {
        await openJoinDialog(tester);

        await tester.tap(find.text('Bekor qilish'));
        await tester.pumpAndSettle();

        expect(find.byType(JoinGroupDialog), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
      });

      testWidgets('teachers have no join tile', (tester) async {
        await openProfile(
          tester,
          _FakeSupabaseService(signedIn: true, role: UserRole.teacher),
        );

        expect(find.text("Guruhga qo'shilish"), findsNothing);
      });
    });

    testWidgets('switching tabs closes an open language sheet', (tester) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));
      await _tapVisible(tester, find.text('Til'));
      expect(find.text('Tilni tanlang'), findsOneWidget);

      // The sheet opens on the tab navigator, so the bar stays tappable.
      await tester.tap(
        find.descendant(
          of: find.byType(LearnistNavBar),
          matching: find.text('AI Lab'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiLabScreen), findsOneWidget);
      expect(find.text('Tilni tanlang'), findsNothing);

      // Back on Profile, nothing is left floating either.
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Tilni tanlang'), findsNothing);
    });

    testWidgets('error map is a menu item, not embedded in the profile', (
      tester,
    ) async {
      await openProfile(tester, _FakeSupabaseService(signedIn: true));

      expect(find.text('Xatolar xaritasi'), findsOneWidget);
      expect(find.byType(ErrorPatternCard), findsNothing);
      expect(find.byIcon(Icons.troubleshoot), findsOneWidget);
    });

    ({TrackedMistake mistake, bool resolved}) row(
      int lesson,
      String section,
      int index,
      int frequency, {
      bool resolved = false,
    }) => (
      mistake: TrackedMistake(
        lessonNumber: lesson,
        section: section,
        questionIndex: index,
        frequency: frequency,
      ),
      resolved: resolved,
    );

    Future<void> openErrorMap(
      WidgetTester tester,
      FakeProgressService progress,
    ) async {
      // Tall view so the lazy ListView builds every card.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await openProfile(
        tester,
        _FakeSupabaseService(signedIn: true),
        progress: progress,
      );
      await _tapVisible(tester, find.text('Xatolar xaritasi'));
      expect(find.byType(ErrorMapScreen), findsOneWidget);
    }

    Color dotColor(WidgetTester tester, String rule) {
      final card = find.ancestor(
        of: find.text(rule),
        matching: find.byType(ErrorPatternCard),
      );
      return tester.widget<ErrorPatternCard>(card).pattern.severity.color;
    }

    testWidgets('error map lists recurring patterns and opens the lesson', (
      tester,
    ) async {
      await openErrorMap(
        tester,
        FakeProgressService(
          mistakes: [
            row(1, 'listening', 5, 3),
            row(1, 'reading', 6, 4),
            row(1, 'reading', 7, 2),
            // A single slip is not a pattern yet.
            row(1, 'reading', 0, 1),
            // Fixed since: resolved mistakes leave the map.
            row(1, 'listening', 0, 6, resolved: true),
          ],
        ),
      );

      expect(find.byType(LearnistNavBar), findsNothing);
      expect(find.byType(ErrorPatternCard), findsNWidgets(3));
      // Most frequent first.
      final rules = tester
          .widgetList<ErrorPatternCard>(find.byType(ErrorPatternCard))
          .map((card) => card.pattern.rule);
      expect(rules, [
        'Subject pronouns: am / is / are',
        'Questions with to be: Are you…? / Is he…?',
        'Vocabulary: orientation',
      ]);
      expect(
        find.text("So'nggi testlarda 4 marta xato qilingan"),
        findsOneWidget,
      );
      expect(find.text('She are a student.'), findsOneWidget);
      expect(find.text('She is a student.'), findsOneWidget);
      expect(
        dotColor(tester, 'Subject pronouns: am / is / are'),
        AppColors.danger,
      );
      expect(dotColor(tester, 'Vocabulary: orientation'), AppColors.warning);
      expect(find.text('Reading: 1-savol'), findsNothing);
      expect(find.text('Listening: 1-savol'), findsNothing);

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

    testWidgets('mistakes missing from the registry get a generic card', (
      tester,
    ) async {
      await openErrorMap(
        tester,
        FakeProgressService(mistakes: [row(3, 'listening', 2, 5)]),
      );

      expect(find.text('Listening: 3-savol'), findsOneWidget);
      expect(find.text('Lesson 3'), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsNothing);
      expect(dotColor(tester, 'Listening: 3-savol'), AppColors.danger);
    });

    testWidgets('no recurring mistakes shows the empty state', (tester) async {
      await openErrorMap(
        tester,
        FakeProgressService(
          mistakes: [
            row(1, 'reading', 6, 1),
            row(1, 'reading', 7, 5, resolved: true),
          ],
        ),
      );

      expect(find.byType(ErrorPatternCard), findsNothing);
      expect(
        find.text("Ajoyib! Hozircha takrorlangan xatolar yo'q"),
        findsOneWidget,
      );
      expect(find.byIcon(LucideIcons.badgeCheck), findsOneWidget);
    });

    testWidgets('a failed load retries into the map', (tester) async {
      final progress = FakeProgressService(mistakes: [row(1, 'reading', 6, 2)])
        ..mistakesError = Exception('down');
      await openErrorMap(tester, progress);

      expect(find.textContaining('Nimadir xato ketdi'), findsOneWidget);
      progress.mistakesError = null;
      await _tapVisible(tester, find.text('Qayta urinish'));

      expect(find.text('Subject pronouns: am / is / are'), findsOneWidget);
    });

    testWidgets('the map refetches after a graded quiz', (tester) async {
      final progress = FakeProgressService(mistakes: [row(1, 'reading', 6, 1)]);
      await openErrorMap(tester, progress);
      expect(find.byType(ErrorPatternCard), findsNothing);

      progress.mistakes[0] = row(1, 'reading', 6, 2);
      await progress.saveMistakes(1, 'reading', [6]);
      await tester.pumpAndSettle();

      expect(find.text('Subject pronouns: am / is / are'), findsOneWidget);
    });

    test('only recurring patterns are kept, most frequent first', () {
      ErrorPattern pattern(String rule, int count) => ErrorPattern(
        rule: rule,
        example: '',
        correction: '',
        mistakeCount: count,
        lessonLabel: '',
        lessonNumber: 1,
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

    testWidgets('edit form is pre-filled and saving needs a change', (
      tester,
    ) async {
      await openEditProfile(tester, editableUser());

      expect(find.text('Profilni tahrirlash'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Aziz Karimov'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'aziz'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(_byKey('edit-full-name'), 'Aziz K.');
      await tester.pump();
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('empty metadata shows placeholder hints, not values', (
      tester,
    ) async {
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

    testWidgets('an unchanged username skips the availability check', (
      tester,
    ) async {
      // "aziz" is reported taken — by this same user.
      final auth = editableUser(taken: {'aziz'});
      await openEditProfile(tester, auth);

      await tester.enterText(_byKey('edit-full-name'), 'Aziz Karimov Jr');
      await _tapVisible(tester, _byKey('edit-save'));

      expect(auth.lastProfileUpdate?['username'], 'aziz');
    });

    testWidgets('saving updates the profile and returns to it', (tester) async {
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

    testWidgets('save failures stay on the form with an Uzbek message', (
      tester,
    ) async {
      final auth =
          editableUser()
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
    testWidgets('greets the user by first name and renders all sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _FakeSupabaseService(signedIn: true, fullName: 'Demirbek Razzaqov'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(', Demirbek 👋'), findsOneWidget);
      expect(find.text("TODAY'S FOCUS"), findsOneWidget);
      // No metadata yet: lesson 1 and no CEFR level.
      expect(find.text('Continue Lesson 1'), findsOneWidget);
      expect(find.text('N/A'), findsNWidgets(2)); // badge + snapshot tile
      expect(find.text('Learning space'), findsOneWidget);
      // No stats yet: nothing mastered, no mistakes.
      expect(find.text('0/52'), findsOneWidget);
      expect(find.text('0% mastery'), findsOneWidget);
    });

    testWidgets('snapshot and mastery bar show the stats', (tester) async {
      await tester.pumpWidget(
        _app(
          _FakeSupabaseService(signedIn: true),
          progress: FakeProgressService(
            progress: const UserProgress(currentLesson: 5),
            stats: const UserStats(
              lessonsMastered: 4,
              currentLessonMastery: 63,
              overallAverage: 88,
              trackedMistakes: 7,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Lessons mastered: 4/52'), findsOneWidget);
      expect(find.bySemanticsLabel('Tracked mistakes: 7'), findsOneWidget);
      expect(find.text('63% mastery'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Lesson mastery, Lesson 5: 63%'),
        findsOneWidget,
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.descendant(
          of: find.byType(LessonMasteryProgress),
          matching: find.byType(LinearProgressIndicator),
        ),
      );
      expect(bar.value, closeTo(0.63, 1e-9));
    });

    testWidgets('home stats refresh after a lesson task is saved', (
      tester,
    ) async {
      final progress = FakeProgressService();
      await tester.pumpWidget(
        _app(_FakeSupabaseService(signedIn: true), progress: progress),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Tracked mistakes: 0'), findsOneWidget);

      progress.stats = const UserStats(trackedMistakes: 3);
      await progress.saveMistakes(1, 'reading', [0, 1, 2]);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Tracked mistakes: 3'), findsOneWidget);
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

    testWidgets('shows the stored level and continues the current lesson', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _FakeSupabaseService(signedIn: true),
          progress: FakeProgressService(
            progress: const UserProgress(cefrLevel: 'B2', currentLesson: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('N/A'), findsNothing);
      expect(
        find.descendant(
          of: _byKey('home-cefr-badge'),
          matching: find.text('B2'),
        ),
        findsOneWidget,
      );
      expect(find.text('UZ'), findsNothing);

      await _tapVisible(tester, _byKey('home-continue-lesson'));
      final screen = tester.widget<LessonDetailScreen>(
        find.byType(LessonDetailScreen),
      );
      expect(screen.lessonId, 5);
    });

    testWidgets('home refetches progress when the auth state changes', (
      tester,
    ) async {
      final auth = _FakeSupabaseService(signedIn: true);
      final progress = FakeProgressService();
      await tester.pumpWidget(_app(auth, progress: progress));
      await tester.pumpAndSettle();
      expect(find.text('Continue Lesson 1'), findsOneWidget);

      progress.progress = const UserProgress(cefrLevel: 'A2', currentLesson: 3);
      auth.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.text('Continue Lesson 3'), findsOneWidget);
    });

    testWidgets('a failed progress fetch falls back to defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _FakeSupabaseService(signedIn: true),
          progress: FakeProgressService()..progressError = Exception('down'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Continue Lesson 1'), findsOneWidget);
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

  group('teacher role', () {
    _FakeSupabaseService teacher() => _FakeSupabaseService(
      signedIn: true,
      fullName: 'Dilnoza Karimova',
      role: UserRole.teacher,
    );

    testWidgets('sign up as a teacher stores the teacher role', (tester) async {
      final auth = _FakeSupabaseService(signedIn: false);
      await tester.pumpWidget(_app(auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(_byKey('auth-role-teacher'));
      await tester.pumpAndSettle();

      await _selectUniversity(tester, 'Boshqa', 'Boshqa / Other');
      await _fillCommonSignUpFields(tester, username: 'teacher_01');
      await tester.enterText(_byKey('auth-other-university'), 'My College');
      await _tapVisible(tester, _byKey('auth-submit'));

      expect(auth.lastSignUp?['role'], 'teacher');
    });

    testWidgets('students have no panel tab and are redirected away', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_FakeSupabaseService(signedIn: true)));
      await tester.pumpAndSettle();

      expect(find.text('Panel'), findsNothing);

      final router = GoRouter.of(tester.element(find.byType(HomeScreen)));
      router.go('/teacher-panel');
      await tester.pumpAndSettle();
      expect(find.byType(TeacherPanelScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    Future<int> lockedTopicCount(
      WidgetTester tester,
      _FakeSupabaseService auth,
    ) async {
      await tester.pumpWidget(_app(auth));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();
      return tester
          .widgetList<TopicCard>(find.byType(TopicCard))
          .where((card) => card.locked)
          .length;
    }

    testWidgets('students still see locked topics', (tester) async {
      final auth = _FakeSupabaseService(signedIn: true);
      expect(await lockedTopicCount(tester, auth), greaterThan(0));
    });

    testWidgets('teachers bypass every topic lock', (tester) async {
      expect(await lockedTopicCount(tester, teacher()), 0);
    });

    // What get_teacher_dashboard and get_student_detail return.
    FakeTeacherService teacherData() => FakeTeacherService(
      dashboard: const TeacherDashboard(
        totalStudents: 1,
        totalGroups: 1,
        averageMastery: 93,
        groups: [
          ClassGroup(
            id: 'g1',
            name: 'English group 301',
            login: 'ELT301',
            password: 'elt301',
            students: [
              TeacherStudent(
                id: 's1',
                fullName: 'Demirbek Razzaqov',
                username: 'redscorpnoir',
                currentLesson: 2,
                masteryPercent: 93,
                cefrLevel: 'C2',
              ),
            ],
          ),
        ],
      ),
      studentLessons: {
        's1': [
          const LessonSkillProgress(
            lessonNumber: 2,
            title: 'A world of sport',
            isCurrent: true,
            reading: 100,
          ),
          const LessonSkillProgress(
            lessonNumber: 1,
            title: 'Hello, everybody!',
            grammar: 85,
          ),
        ],
      },
    );

    testWidgets('teacher opens the panel and a student detail dialog', (
      tester,
    ) async {
      await tester.pumpWidget(_app(teacher(), teacher: teacherData()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Panel'));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherPanelScreen), findsOneWidget);
      expect(find.text("O'qituvchi paneli"), findsOneWidget);
      expect(find.text('English group 301'), findsOneWidget);
      expect(find.text('Common issues'), findsNothing);

      await _tapVisible(tester, find.text('View'));
      expect(find.byType(StudentDetailDialog), findsOneWidget);
      expect(find.text('@redscorpnoir • current Lesson 2'), findsOneWidget);
      expect(find.textContaining('Grammar 85%'), findsOneWidget);
      expect(find.textContaining('Reading 100%'), findsOneWidget);

      await tester.tap(_byKey('student-detail-close'));
      await tester.pumpAndSettle();
      expect(find.byType(StudentDetailDialog), findsNothing);
    });

    testWidgets('wide screens use the sidebar with the full label', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(teacher(), teacher: teacherData()));
      await tester.pumpAndSettle();

      expect(find.byType(LearnistSidebar), findsOneWidget);
      expect(find.byType(LearnistNavBar), findsNothing);

      await tester.tap(find.text("O'qituvchi paneli"));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherPanelScreen), findsOneWidget);
      expect(find.text('TALABA'), findsOneWidget);
    });
  });

  group('topics screen', () {
    Future<void> openTopics(
      WidgetTester tester, {
      _FakeSupabaseService? auth,
      FakeLessonService? lessons,
      FakeProgressService? progress,
      bool settle = true,
    }) async {
      await tester.pumpWidget(
        _app(
          auth ?? _FakeSupabaseService(signedIn: true),
          lessons: lessons,
          progress: progress,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Topics'));
      settle ? await tester.pumpAndSettle() : await tester.pump();
    }

    testWidgets('shows a spinner until lessons arrive', (tester) async {
      final lessons = FakeLessonService(pending: Completer<void>());
      await openTopics(tester, lessons: lessons, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TopicCard), findsNothing);

      lessons.pending!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('1. Hello, everybody!'), findsOneWidget);
      expect(find.text('Semester 1'), findsWidgets);
      expect(find.text('A1'), findsWidgets);
    });

    testWidgets('fetches once, not on every rebuild', (tester) async {
      final lessons = FakeLessonService();
      await openTopics(tester, lessons: lessons);
      await tester.enterText(find.byType(TextField), 'sport');
      await tester.pumpAndSettle();

      expect(lessons.fetchCount, 1);
      expect(find.text('2. A world of sport'), findsOneWidget);
      expect(find.text('1. Hello, everybody!'), findsNothing);
    });

    testWidgets('an error shows a message and retry refetches', (tester) async {
      final lessons = FakeLessonService(
        error: const PostgrestException(message: 'boom'),
      );
      await openTopics(tester, lessons: lessons);

      expect(find.textContaining("Darslarni yuklab bo'lmadi"), findsOneWidget);
      expect(find.byType(TopicCard), findsNothing);

      lessons.error = null;
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();
      expect(lessons.fetchCount, 2);
      expect(find.text('1. Hello, everybody!'), findsOneWidget);
    });

    testWidgets('search reaches semester 2 lessons', (tester) async {
      await openTopics(tester);
      await tester.enterText(find.byType(TextField), 'white gold');
      await tester.pumpAndSettle();

      // Header and card pill.
      expect(find.text('Semester 2'), findsNWidgets(2));
      expect(find.text('38. White Gold'), findsOneWidget);
    });

    testWidgets('students open lesson 1; later lessons say Qulflangan', (
      tester,
    ) async {
      await openTopics(tester);

      await tester.tap(find.text('2. A world of sport'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Qulflangan'), findsOneWidget);
      expect(find.byType(LessonDetailScreen), findsNothing);

      await tester.tap(find.text('1. Hello, everybody!'));
      await tester.pumpAndSettle();
      final screen = tester.widget<LessonDetailScreen>(
        find.byType(LessonDetailScreen),
      );
      expect(screen.lessonId, 1);
    });

    testWidgets('students can open lessons up to current_lesson', (
      tester,
    ) async {
      await openTopics(
        tester,
        progress: FakeProgressService(
          progress: const UserProgress(currentLesson: 2),
        ),
      );

      await tester.tap(find.text('3. The digital era'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Qulflangan'), findsOneWidget);

      await tester.tap(find.text('2. A world of sport'));
      await tester.pumpAndSettle();
      final screen = tester.widget<LessonDetailScreen>(
        find.byType(LessonDetailScreen),
      );
      expect(screen.lessonId, 2);
    });

    testWidgets('completing the current lesson unlocks the next one', (
      tester,
    ) async {
      final progress = FakeProgressService();
      await openTopics(tester, progress: progress);

      await tester.tap(find.text('1. Hello, everybody!'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gapirish'));
      await tester.pumpAndSettle();

      final complete = find.byKey(const ValueKey('complete-lesson'));
      await tester.scrollUntilVisible(
        complete,
        300,
        scrollable:
            find
                .descendant(
                  of: find.byType(SpeakingTab),
                  matching: find.byType(Scrollable),
                )
                .first,
      );
      // scrollUntilVisible stops once the button's edge shows.
      await tester.ensureVisible(complete);
      await tester.pumpAndSettle();
      await tester.tap(complete);
      await tester.pumpAndSettle();

      expect(progress.completedLessons, [1]);
      expect(find.byType(LessonDetailScreen), findsNothing);
      expect(find.byType(TopicsScreen), findsOneWidget);
      expect(find.text('Tabriklaymiz! Yangi dars ochildi'), findsOneWidget);

      await tester.tap(find.text('2. A world of sport'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Qulflangan'), findsNothing);
      final screen = tester.widget<LessonDetailScreen>(
        find.byType(LessonDetailScreen),
      );
      expect(screen.lessonId, 2);
    });

    testWidgets('teachers open any lesson by number', (tester) async {
      await openTopics(
        tester,
        auth: _FakeSupabaseService(signedIn: true, role: UserRole.teacher),
      );

      await tester.tap(find.text('2. A world of sport'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Qulflangan'), findsNothing);
      final screen = tester.widget<LessonDetailScreen>(
        find.byType(LessonDetailScreen),
      );
      expect(screen.lessonId, 2);
    });

    testWidgets('a malformed lesson id redirects to the list', (tester) async {
      await openTopics(tester);
      GoRouter.of(
        tester.element(find.byType(TopicsScreen)),
      ).go('/lesson-detail/abc');
      await tester.pumpAndSettle();

      expect(find.byType(LessonDetailScreen), findsNothing);
      expect(find.byType(TopicsScreen), findsOneWidget);
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
        message:
            '{"code":500,"error_code":"unexpected_failure",'
            '"msg":"Database error saving new user"}',
        statusCode: '500',
      );
      expect(authErrorMessage(error), usernameTakenMessage);
    });

    test('server and database errors are not reported as network errors', () {
      expect(
        authErrorMessage(
          AuthRetryableFetchException(
            message: 'Bad gateway',
            statusCode: '502',
          ),
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
