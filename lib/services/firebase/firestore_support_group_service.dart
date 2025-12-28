import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/support_group_model.dart';

/// Firestore service for SupportGroup entity
class FirestoreSupportGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'support_groups';

  /// Get support group by ID
  Future<SupportGroupModel?> getSupportGroup(String supportGroupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(supportGroupId).get();
      if (!doc.exists) return null;
      return SupportGroupModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get support group: $e');
    }
  }

  /// Create support group
  Future<String> createSupportGroup(SupportGroupModel supportGroup) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            supportGroup.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create support group: $e');
    }
  }

  /// Update support group
  Future<void> updateSupportGroup(String supportGroupId, SupportGroupModel supportGroup) async {
    try {
      await _firestore.collection(_collection).doc(supportGroupId).update(
            supportGroup.copyWith(id: supportGroupId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update support group: $e');
    }
  }

  /// Delete support group
  Future<void> deleteSupportGroup(String supportGroupId) async {
    try {
      await _firestore.collection(_collection).doc(supportGroupId).delete();
    } catch (e) {
      throw Exception('Failed to delete support group: $e');
    }
  }

  /// Get all support groups
  Stream<List<SupportGroupModel>> getAllSupportGroups() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportGroupModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }
}

