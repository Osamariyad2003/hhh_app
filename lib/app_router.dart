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

import 'screens/ai_suggestion_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/patient_stories_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/general_childcare_screen_simple.dart';

GoRouter createAppRouter(AppCubit appCubit, AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      GoRouterRefreshCubit(appCubit),
      GoRouterRefreshAuthCubit(authCubit),
    ]),
    redirect: (context, state) {
      final appState = appCubit.state;

      if (!appState.initialized) {
        return '/splash';
      }

      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;
      final isUnauthenticated = authState is AuthUnauthenticated;

      final currentPath = state.uri.toString();
      final isAuthRoute = currentPath == '/login' || currentPath == '/signup';
      final isSplashRoute = currentPath == '/splash';

      if (isInitial) {
        if (isSplashRoute) return null; 
        return '/splash'; 
      }

      if (!isAuthenticated) {
        if (isAuthRoute) return null; 
        if (isSplashRoute) {
          return '/login';
        }
        return '/login';
      }

      if (isAuthenticated) {
        if (isAuthRoute || isSplashRoute) {
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
        path: '/ai-suggestions',
        builder: (context, state) => const AISuggestionScreen(),
      ),
      GoRoute(
        path: '/general-childcare',
        builder: (context, state) => const GeneralChildcareScreenSimple(),
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
