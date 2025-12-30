import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firebase_user_model.dart';
import 'firebase/firestore_user_service.dart';

class FirebaseAuthService {
  FirebaseAuthService._();
  static final instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();
  final _authStateController = StreamController<User?>.broadcast();

  Stream<User?> authStateChanges() {
    _auth.authStateChanges().listen((user) {
      _authStateController.add(user);
    });
    return _authStateController.stream;
  }

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

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

      await _userService.updateLastLogin(credential.user!.uid);

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

  Future<FirebaseUserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed: User is null');
      }

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

  Future<FirebaseUserModel> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user == null) {
        throw Exception('Anonymous sign in failed: User is null');
      }

      final userProfile = FirebaseUserModel(
        id: credential.user!.uid,
        username: 'Anonymous',
        email: '',
        role: 'parent', 
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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _authStateController.add(null);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<FirebaseUserModel?> getCurrentUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _userService.getUser(userId);
  }

  Future<void> updateUserProfile(FirebaseUserModel user) async {
    await _userService.setUser(user);
  }

  Future<bool> isAdmin() async {
    return false;
  }

  Future<bool> isParent() async {
    final profile = await getCurrentUserProfile();
    return profile?.role == 'parent';
  }

  Future<bool> isHospital() async {
    return await isParent();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

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

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

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
