import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/support_group_model.dart';

class FirestoreSupportGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'support_groups';

  Future<SupportGroupModel?> getSupportGroup(String supportGroupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(supportGroupId).get();
      if (!doc.exists) return null;
      return SupportGroupModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get support group: $e');
    }
  }

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

  Future<void> updateSupportGroup(String supportGroupId, SupportGroupModel supportGroup) async {
    try {
      await _firestore.collection(_collection).doc(supportGroupId).update(
            supportGroup.copyWith(id: supportGroupId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update support group: $e');
    }
  }

  Future<void> deleteSupportGroup(String supportGroupId) async {
    try {
      await _firestore.collection(_collection).doc(supportGroupId).delete();
    } catch (e) {
      throw Exception('Failed to delete support group: $e');
    }
  }

  Stream<List<SupportGroupModel>> getAllSupportGroups() {
    print('DEBUG: Fetching support groups stream...');
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) {
            print('DEBUG: Support groups snapshot received. Docs: ${snapshot.docs.length}');
            final groups = snapshot.docs.map((doc) {
              try {
                return SupportGroupModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                });
              } catch (e) {
                print('DEBUG: Error parsing support group ${doc.id}: $e');
                rethrow;
              }
            }).toList();
            print('DEBUG: Parsed ${groups.length} support groups.');
            return groups;
          },
        );
  }
}

