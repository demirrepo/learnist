import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/ai_lab_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/level_check_screen.dart';
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
  static const aiLab = '/ai-lab';
  static const levelCheck = '/level-check';
  static const profile = '/profile';
}

/// Exposed as a provider so the redirect can read auth state.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(supabaseServiceProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    // Re-run redirect on sign-in, sign-out and password recovery.
    refreshListenable: auth,
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
          ),
          GoRoute(
            path: AppRoutes.aiLab,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AiLabScreen()),
          ),
          GoRoute(
            path: AppRoutes.levelCheck,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LevelCheckScreen()),
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

  ref.onDispose(router.dispose);
  return router;
});
