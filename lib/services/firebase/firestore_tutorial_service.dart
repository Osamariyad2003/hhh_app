import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/tutorial_model.dart';

/// Firestore service for Tutorial entity
class FirestoreTutorialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tutorials';

  /// Get tutorial by ID
  Future<TutorialModel?> getTutorial(String tutorialId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(tutorialId).get();
      if (!doc.exists) return null;
      return TutorialModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get tutorial: $e');
    }
  }

  /// Create tutorial
  Future<String> createTutorial(TutorialModel tutorial) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            tutorial.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create tutorial: $e');
    }
  }

  /// Update tutorial
  Future<void> updateTutorial(String tutorialId, TutorialModel tutorial) async {
    try {
      await _firestore.collection(_collection).doc(tutorialId).update(
            tutorial.copyWith(id: tutorialId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update tutorial: $e');
    }
  }

  /// Delete tutorial
  Future<void> deleteTutorial(String tutorialId) async {
    try {
      await _firestore.collection(_collection).doc(tutorialId).delete();
    } catch (e) {
      throw Exception('Failed to delete tutorial: $e');
    }
  }

  /// Get all tutorials
  Stream<List<TutorialModel>> getAllTutorials() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TutorialModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get tutorials by category
  Stream<List<TutorialModel>> getTutorialsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TutorialModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }
}

