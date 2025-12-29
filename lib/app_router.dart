import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cubits/app_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/auth_states.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/home_screen.dart';
import 'screens/section_screen.dart';
import 'screens/tutorials_screen.dart';
import 'screens/tutorial_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'models/tutorial_item.dart';
import 'screens/settings_screen.dart';
import 'screens/track_dashboard_screen.dart';
import 'screens/track_home_screen.dart';
import 'screens/add_child_screen.dart';
import 'screens/child_detail_screen.dart';
import 'screens/child_info_screen.dart';
import 'screens/heart_prediction_screen.dart';
import 'screens/ai_suggestion_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/patient_stories_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/general_childcare_screen.dart';
import 'cubits/general_childcare_cubit.dart';

GoRouter createAppRouter(AppCubit appCubit, AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      GoRouterRefreshCubit(appCubit),
      GoRouterRefreshAuthCubit(authCubit),
    ]),
    redirect: (context, state) {
      final appState = appCubit.state;

      // Wait for app initialization
      if (!appState.initialized) {
        return '/splash';
      }

      // Check authentication state
      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;
      final isUnauthenticated = authState is AuthUnauthenticated;

      // Get current route
      final currentPath = state.uri.toString();
      final isAuthRoute = currentPath == '/login' || currentPath == '/signup';
      final isSplashRoute = currentPath == '/splash';

      // If still initializing auth (checking Firebase auth state), stay on splash
      if (isInitial) {
        if (isSplashRoute) return null; // Allow staying on splash
        return '/splash'; // Redirect to splash while checking auth
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated) {
        if (isAuthRoute) return null; // Allow access to auth screens
        if (isSplashRoute) {
          // If on splash and not authenticated, go to login
          return '/login';
        }
        return '/login';
      }

      // If authenticated, redirect away from auth screens and splash
      if (isAuthenticated) {
        if (isAuthRoute || isSplashRoute) {
          // Redirect authenticated users away from auth screens
          return '/';
        }

        // Check lock screen
        final lockEnabled = appState.lockEnabled;
        final unlocked = appState.unlocked;
        final goingToLock = currentPath == '/lock';

        if (lockEnabled && !unlocked) {
          return goingToLock ? null : '/lock';
        }

        if (goingToLock && unlocked) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      
      // Main navigation routes with bottom bar
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationScreen(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainNavigationScreen(
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/track',
        builder: (context, state) {
          final childId = state.uri.queryParameters['childId'];
          return MainNavigationScreen(
            child: TrackDashboardScreen(initialChildId: childId),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainNavigationScreen(
          child: ProfileScreen(),
        ),
      ),

      // Nested routes (no bottom bar)
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
        path: '/patient-stories',
        builder: (context, state) => const PatientStoriesScreen(),
      ),
      GoRoute(
        path: '/tutorial/:id',
        builder: (context, state) {
          final tutorial = state.extra as TutorialItem?;
          if (tutorial == null) {
            // Fallback - try to get from state if available
            return const TutorialsScreen();
          }
          return TutorialDetailScreen(tutorial: tutorial);
        },
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
        path: '/general-childcare',
        builder: (context, state) => BlocProvider(
          create: (context) => GeneralChildcareCubit(),
          child: const GeneralChildcareScreen(),
        ),
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
        path: '/track/child-info/:childId',
        builder: (context, state) =>
            ChildInfoScreen(childId: state.pathParameters['childId']!),
      ),
      GoRoute(
        path: '/track/child/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final tab = state.uri.queryParameters['tab'];
          return ChildDetailScreen(childId: childId, initialTab: tab);
        },
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

class GoRouterRefreshAuthCubit extends ChangeNotifier {
  GoRouterRefreshAuthCubit(AuthCubit cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
