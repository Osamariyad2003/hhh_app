import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'cubits/app_cubit.dart';
import 'services/auth_service.dart';

import 'screens/splash_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/home_screen.dart';
import 'screens/section_screen.dart';
import 'screens/tutorials_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/track_dashboard_screen.dart';
import 'screens/track_home_screen.dart';
import 'screens/add_child_screen.dart';
import 'screens/child_detail_screen.dart';
import 'screens/heart_prediction_screen.dart';
import 'screens/ai_suggestion_screen.dart';

GoRouter createAppRouter(AppCubit appCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(AuthService.instance.authStateChanges()),
      GoRouterRefreshCubit(appCubit),
    ]),
    redirect: (context, state) {
      final appState = appCubit.state;

      if (!appState.initialized) return '/splash';

      final loggedIn = AuthService.instance.currentUserId != null;
      final goingToSplash = state.uri.toString() == '/splash';

      if (!loggedIn) {
        return goingToSplash ? null : '/splash';
      }

      final lockEnabled = appState.lockEnabled;
      final unlocked = appState.unlocked;
      final goingToLock = state.uri.toString() == '/lock';

      if (lockEnabled && !unlocked) {
        return goingToLock ? null : '/lock';
      }

      if (goingToLock) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

      GoRoute(
        path: '/section/:id',
        builder: (context, state) =>
            SectionScreen(sectionId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: '/tutorials',
        builder: (context, state) => const TutorialsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/heart-prediction',
        builder: (context, state) => const HeartPredictionScreen(),
      ),
      GoRoute(
        path: '/ai-suggestions',
        builder: (context, state) => const AISuggestionScreen(),
      ),

      GoRoute(
        path: '/track',
        builder: (context, state) => const TrackDashboardScreen(),
      ),
      GoRoute(
        path: '/track/manage',
        builder: (context, state) => const TrackHomeScreen(),
      ),
      GoRoute(
        path: '/track/add-child',
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/track/child/:childId',
        builder: (context, state) =>
            ChildDetailScreen(childId: state.pathParameters['childId']!),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class GoRouterRefreshCubit extends ChangeNotifier {
  GoRouterRefreshCubit(AppCubit cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AppState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
