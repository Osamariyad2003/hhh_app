import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firebase_user_model.dart';
import 'firebase/firestore_user_service.dart';

/// Firebase Authentication Service
class FirebaseAuthService {
  FirebaseAuthService._();
  static final instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();
  final _authStateController = StreamController<User?>.broadcast();

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    // Listen to Firebase auth changes and forward to controller
    _auth.authStateChanges().listen((user) {
      _authStateController.add(user);
    });
    return _authStateController.stream;
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with email and password
  Future<FirebaseUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: User is null');
      }

      // Update last login
      await _userService.updateLastLogin(credential.user!.uid);

      // Get user profile from Firestore
      final userProfile = await _userService.getUser(credential.user!.uid);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<FirebaseUserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String role, // "parent" - all users are parents
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed: User is null');
      }

      // Create user profile in Firestore
      final userProfile = FirebaseUserModel(
        id: credential.user!.uid,
        username: username,
        email: email,
        role: role,
        isActive: true,
        lastLogin: DateTime.now(),
      );

      await _userService.setUser(userProfile);

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in anonymously
  Future<FirebaseUserModel> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user == null) {
        throw Exception('Anonymous sign in failed: User is null');
      }

      // Create anonymous user profile in Firestore
      final userProfile = FirebaseUserModel(
        id: credential.user!.uid,
        username: 'Anonymous',
        email: '',
        role: 'parent', // Default role for anonymous users (parents)
        isActive: true,
        lastLogin: DateTime.now(),
      );

      await _userService.setUser(userProfile);

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw Exception('Anonymous sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Anonymous sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _authStateController.add(null);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user profile from Firestore
  Future<FirebaseUserModel?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _userService.getUser(userId);
  }

  /// Update user profile
  Future<void> updateUserProfile(FirebaseUserModel user) async {
    await _userService.setUser(user);
  }

  /// Check if user is admin (deprecated - all users are parents now)
  Future<bool> isAdmin() async {
    // All users are parents, no admin role
    return false;
  }

  /// Check if user is a parent
  Future<bool> isParent() async {
    final profile = await getCurrentUserProfile();
    return profile?.role == 'parent';
  }

  /// Check if user is hospital (deprecated - use isParent instead)
  Future<bool> isHospital() async {
    // All users are parents now
    return await isParent();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      if (user.email == null) {
        throw Exception('User email is null');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password change failed: ${e.message}');
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
