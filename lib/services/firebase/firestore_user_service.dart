import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/firebase_user_model.dart';

/// Firestore service for User entity
class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Get user by ID
  Future<FirebaseUserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) return null;
      return FirebaseUserModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Create or update user
  Future<void> setUser(FirebaseUserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to set user: $e');
    }
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get all users
  Stream<List<FirebaseUserModel>> getAllUsers() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseUserModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get users by role
  Stream<List<FirebaseUserModel>> getUsersByRole(String role) {
    return _firestore
        .collection(_collection)
        .where('role', isEqualTo: role)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseUserModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    await updateUser(userId, {'lastLogin': DateTime.now().toIso8601String()});
  }
}

