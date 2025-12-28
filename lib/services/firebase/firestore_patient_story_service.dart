import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_story_model.dart';

/// Firestore service for PatientStory entity
class FirestorePatientStoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'patient_stories';

  /// Get patient story by ID
  Future<PatientStoryModel?> getPatientStory(String patientStoryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(patientStoryId).get();
      if (!doc.exists) return null;
      return PatientStoryModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get patient story: $e');
    }
  }

  /// Create patient story
  Future<String> createPatientStory(PatientStoryModel story) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            story.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create patient story: $e');
    }
  }

  /// Update patient story
  Future<void> updatePatientStory(String patientStoryId, PatientStoryModel story) async {
    try {
      await _firestore.collection(_collection).doc(patientStoryId).update(
            story.copyWith(id: patientStoryId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update patient story: $e');
    }
  }

  /// Delete patient story
  Future<void> deletePatientStory(String patientStoryId) async {
    try {
      await _firestore.collection(_collection).doc(patientStoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete patient story: $e');
    }
  }

  /// Get all patient stories
  Stream<List<PatientStoryModel>> getAllPatientStories() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientStoryModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get published patient stories
  Stream<List<PatientStoryModel>> getPublishedPatientStories() {
    return _firestore
        .collection(_collection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientStoryModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get featured patient stories
  Stream<List<PatientStoryModel>> getFeaturedPatientStories() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientStoryModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Publish/unpublish patient story
  Future<void> setPublished(String patientStoryId, bool isPublished) async {
    try {
      await _firestore.collection(_collection).doc(patientStoryId).update({
        'isPublished': isPublished,
      });
    } catch (e) {
      throw Exception('Failed to update publish status: $e');
    }
  }

  /// Feature/unfeature patient story
  Future<void> setFeatured(String patientStoryId, bool isFeatured) async {
    try {
      await _firestore.collection(_collection).doc(patientStoryId).update({
        'isFeatured': isFeatured,
      });
    } catch (e) {
      throw Exception('Failed to update featured status: $e');
    }
  }
}

