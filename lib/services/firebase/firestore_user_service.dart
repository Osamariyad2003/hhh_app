import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/firebase_user_model.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  Future<FirebaseUserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) return null;
      return FirebaseUserModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

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

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

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

  Future<void> updateLastLogin(String userId) async {
    await updateUser(userId, {'lastLogin': DateTime.now().toIso8601String()});
  }
}

