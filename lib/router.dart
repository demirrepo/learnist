import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/ai_lab_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/error_map_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lesson_detail_screen.dart';
import 'screens/checkup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/topics_screen.dart';
import 'screens/update_password_screen.dart';
import 'services/supabase_service.dart';
import 'widgets/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Route paths.
abstract final class AppRoutes {
  static const auth = '/auth';
  static const updatePassword = '/update-password';
  static const home = '/home';
  static const topics = '/topics';
  static const lesson = '/topics/lesson';
  static const aiLab = '/ai-lab';
  static const levelCheck = '/level-check';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const errorMap = '/error-map';

  /// Full-screen lesson above the tab shell, so Back returns to whatever
  /// pushed it. [lesson] is the same screen inside the Topics tab.
  static const lessonDetail = '/lesson-detail';
}

/// Exposed as a provider so the redirect can read auth state.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(supabaseServiceProvider);
  final redirectListenable = _AuthRedirectListenable(auth);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    // Re-run redirect on sign-in, sign-out and password recovery.
    refreshListenable: redirectListenable,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // A reset link signs the user in with a recovery session; keep them on
      // the update screen until they save a new password or cancel.
      if (auth.isRecoveringPassword) {
        return location == AppRoutes.updatePassword
            ? null
            : AppRoutes.updatePassword;
      }

      if (!auth.isSignedIn) {
        return location == AppRoutes.auth ? null : AppRoutes.auth;
      }
      if (location == AppRoutes.auth ||
          location == AppRoutes.updatePassword) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.updatePassword,
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      // Full-screen pages above the tab shell; opened with context.push.
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.errorMap,
        builder: (context, state) => const ErrorMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.lessonDetail,
        builder: (context, state) => const LessonDetailScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.topics,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TopicsScreen()),
            routes: [
              GoRoute(
                path: 'lesson',
                builder: (context, state) => const LessonDetailScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.aiLab,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AiLabScreen()),
          ),
          GoRoute(
            path: AppRoutes.levelCheck,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CheckUpScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    redirectListenable.dispose();
  });
  return router;
});

/// Forwards [SupabaseService] notifications only when the redirect inputs
/// change. Other auth events (e.g. a profile metadata update) must not
/// refresh the router: a refresh racing a `context.pop()` restores the page
/// that was just popped.
class _AuthRedirectListenable extends ChangeNotifier {
  _AuthRedirectListenable(this._auth) : _state = _read(_auth) {
    _auth.addListener(_onAuthChanged);
  }

  final SupabaseService _auth;
  ({bool signedIn, bool recovering}) _state;

  static ({bool signedIn, bool recovering}) _read(SupabaseService auth) =>
      (signedIn: auth.isSignedIn, recovering: auth.isRecoveringPassword);

  void _onAuthChanged() {
    final next = _read(_auth);
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
