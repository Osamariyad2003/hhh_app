import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firebase_auth_service.dart';
import '../models/user_model.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final _firebaseAuth = FirebaseAuthService.instance;

  AuthCubit() : super(const AuthInitial()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    emit(const AuthLoading());
    try {
      final userProfile = await _firebaseAuth.getCurrentUserProfile();
      if (userProfile != null) {
        final user = UserModel(
          id: userProfile.id,
          email: userProfile.email,
          name: userProfile.username,
          isAnonymous: userProfile.role == 'parent' && userProfile.email.isEmpty,
        );

        emit(
          AuthAuthenticated(
            user: user,
            token: userId, 
          ),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  Future<void> signInAnonymously() async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.signInAnonymously();
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    String? name,
    String role = 'parent',
  }) async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
        username: name?.trim() ?? email.split('@').first,
        role: role,
      );
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      await _firebaseAuth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      emit(AuthError('User not authenticated', previousState: state));
      return;
    }

    emit(const AuthLoading());

    try {
      final userProfile = await _firebaseAuth.getCurrentUserProfile();
      if (userProfile != null) {
        final updatedProfile = userProfile.copyWith(
          username: name ?? userProfile.username,
          email: email ?? userProfile.email,
        );

        await _firebaseAuth.updateUserProfile(updatedProfile);

        await _loadUserProfile(userProfile.id);
      }
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: currentState,
        ),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email);
    } catch (e) {
      emit(
        AuthError(
          e.toString().replaceAll('Exception: ', ''),
          previousState: state,
        ),
      );
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is AuthError) {
      if (currentState.previousState != null) {
        emit(currentState.previousState!);
      } else {
        emit(const AuthUnauthenticated());
      }
    }
  }

  UserModel? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  bool get isLoading => state is AuthLoading;

  Future<bool> isAdmin() async {
    return await _firebaseAuth.isAdmin();
  }
}
