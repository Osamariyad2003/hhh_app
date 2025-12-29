import 'firebase/firestore_support_group_service.dart';

class SupportGroupService {
  SupportGroupService._();
  static final SupportGroupService instance = SupportGroupService._();

  final _firestoreService = FirestoreSupportGroupService();

  /// Get all support groups
  Future<List<Map<String, dynamic>>> getSupportGroups() async {
    try {
      final groups = await _firestoreService.getAllSupportGroups().first;
      return groups.map((g) => g.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream all support groups
  Stream<List<Map<String, dynamic>>> streamSupportGroups() {
    return _firestoreService.getAllSupportGroups().map(
      (groups) => groups.map((g) => g.toJson()).toList(),
    );
  }

  /// Get support group by ID
  Future<Map<String, dynamic>?> getSupportGroup(String supportGroupId) async {
    try {
      final group = await _firestoreService.getSupportGroup(supportGroupId);
      return group?.toJson();
    } catch (e) {
      return null;
    }
  }
}

