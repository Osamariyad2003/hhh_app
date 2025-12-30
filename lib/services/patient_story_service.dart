import 'firebase/firestore_patient_story_service.dart';

class PatientStoryService {
  PatientStoryService._();
  static final PatientStoryService instance = PatientStoryService._();

  final _firestoreService = FirestorePatientStoryService();

  Future<List<Map<String, dynamic>>> getPublishedStories() async {
    try {
      final stories = await _firestoreService.getPublishedPatientStories().first;
      return stories.map((s) => s.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamPublishedStories() {
    return _firestoreService.getPublishedPatientStories().map(
      (stories) => stories.map((s) => s.toJson()).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getFeaturedStories() async {
    try {
      final stories = await _firestoreService.getFeaturedPatientStories().first;
      return stories.map((s) => s.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamFeaturedStories() {
    return _firestoreService.getFeaturedPatientStories().map(
      (stories) => stories.map((s) => s.toJson()).toList(),
    );
  }

  Future<Map<String, dynamic>?> getStory(String storyId) async {
    try {
      final story = await _firestoreService.getPatientStory(storyId);
      return story?.toJson();
    } catch (e) {
      return null;
    }
  }
}

