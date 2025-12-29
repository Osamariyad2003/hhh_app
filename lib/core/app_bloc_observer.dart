import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global BLoC Observer for debugging and logging
/// Observes all BLoC/Cubit events, state changes, and errors
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      debugPrint('🟢 BLoC Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('📤 Event: ${bloc.runtimeType} -> ${event.runtimeType}');
      if (event.toString() != event.runtimeType.toString()) {
        debugPrint('   Details: $event');
      }
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('🔄 State Change: ${bloc.runtimeType}');
      debugPrint('   Previous: ${change.currentState.runtimeType}');
      debugPrint('   Current:  ${change.nextState.runtimeType}');
      
      // Log state details if they're different from just the type
      final currentStr = change.currentState.toString();
      final nextStr = change.nextState.toString();
      
      if (currentStr != change.currentState.runtimeType.toString()) {
        debugPrint('   Previous Details: $currentStr');
      }
      if (nextStr != change.nextState.runtimeType.toString()) {
        debugPrint('   Current Details:  $nextStr');
      }
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('❌ Error in ${bloc.runtimeType}:');
      debugPrint('   Error: $error');
      debugPrint('   StackTrace: $stackTrace');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      debugPrint('🔴 BLoC Closed: ${bloc.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('➡️  Transition: ${bloc.runtimeType}');
      debugPrint('   Event: ${transition.event.runtimeType}');
      debugPrint('   From: ${transition.currentState.runtimeType}');
      debugPrint('   To: ${transition.nextState.runtimeType}');
    }
  }
}

