import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_story_model.dart';

/// Firestore service for PatientStory entity
/// Connects to Firebase Firestore collection: 'patient_stories'
class FirestorePatientStoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'patient_stories'; // Firebase Firestore collection name

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

  /// Get published patient stories from Firebase Firestore
  /// Queries collection 'patient_stories' where isPublished = true
  /// Returns real-time stream that updates automatically when data changes
  Stream<List<PatientStoryModel>> getPublishedPatientStories() {
    return _firestore
        .collection(_collection) // Firebase collection: 'patient_stories'
        .where('isPublished', isEqualTo: true) // Filter: only published stories
        .snapshots() // Real-time stream from Firebase
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientStoryModel.fromJson({
                    'id': doc.id,
                    ...doc.data(), // Get all fields from Firebase document
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

