import '../models/patient_story_model.dart';
import 'firebase/firestore_patient_story_service.dart';

/// Service for managing patient stories
/// Uses Firebase Firestore to fetch patient stories from 'patient_stories' collection
class PatientStoryService {
  PatientStoryService._();
  static final PatientStoryService instance = PatientStoryService._();

  final _firestoreService = FirestorePatientStoryService();

  /// Get all published patient stories from Firebase
  /// Returns stories where isPublished = true
  Future<List<Map<String, dynamic>>> getPublishedStories() async {
    try {
      final stories = await _firestoreService.getPublishedPatientStories().first;
      return stories.map((s) => s.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream published patient stories from Firebase Firestore
  /// Real-time updates from 'patient_stories' collection
  /// Filters: isPublished = true
  Stream<List<Map<String, dynamic>>> streamPublishedStories() {
    return _firestoreService.getPublishedPatientStories().map(
      (stories) => stories.map((s) => s.toJson()).toList(),
    );
  }

  /// Get featured patient stories
  Future<List<Map<String, dynamic>>> getFeaturedStories() async {
    try {
      final stories = await _firestoreService.getFeaturedPatientStories().first;
      return stories.map((s) => s.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream featured patient stories
  Stream<List<Map<String, dynamic>>> streamFeaturedStories() {
    return _firestoreService.getFeaturedPatientStories().map(
      (stories) => stories.map((s) => s.toJson()).toList(),
    );
  }

  /// Get patient story by ID
  Future<Map<String, dynamic>?> getStory(String storyId) async {
    try {
      final story = await _firestoreService.getPatientStory(storyId);
      return story?.toJson();
    } catch (e) {
      return null;
    }
  }
}

