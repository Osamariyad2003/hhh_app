import '../models/tutorial_model.dart';
import 'firebase/firestore_tutorial_service.dart';

class TutorialService {
  TutorialService._();
  static final TutorialService instance = TutorialService._();

  final _firestoreService = FirestoreTutorialService();

  Future<Map<String, dynamic>> getTutorials({
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      List<TutorialModel> tutorials;
      
      if (category != null && category.trim().isNotEmpty) {
        tutorials = await _firestoreService
            .getTutorialsByCategory(category.trim())
            .first;
      } else {
        tutorials = await _firestoreService.getAllTutorials().first;
      }

      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedTutorials = tutorials.length > startIndex
          ? tutorials.sublist(
              startIndex,
              endIndex > tutorials.length ? tutorials.length : endIndex,
            )
          : <TutorialModel>[];

      return {
        'tutorials': paginatedTutorials.map((t) => t.toJson()).toList(),
        'pagination': {
          'page': page,
          'limit': limit,
          'total': tutorials.length,
          'totalPages': (tutorials.length / limit).ceil(),
        },
      };
    } catch (e) {
      return {
        'tutorials': [],
        'pagination': {
          'page': page,
          'limit': limit,
          'total': 0,
          'totalPages': 0,
        },
        'error': e.toString(),
      };
    }
  }

  Future<String?> createTutorial({
    required String category,
    required String title,
    String? contentEnglish,
    String? contentArabic,
    String? videoUrl,
    String? fileUrl,
    String? imageUrl,
  }) async {
    try {
      const validCategories = [
        'formula_mixes',
        'medication',
        'post_op_care',
        'general',
      ];
      if (!validCategories.contains(category)) {
        throw Exception(
          'Invalid category. Must be one of: ${validCategories.join(", ")}',
        );
      }

      if (title.trim().isEmpty) {
        throw Exception('Title is required');
      }
      if (contentEnglish == null || contentEnglish.trim().isEmpty) {
        throw Exception('English content is required');
      }
      if (imageUrl == null || imageUrl.trim().isEmpty) {
        throw Exception('Image URL is required');
      }

      final tutorial = TutorialModel(
        id: '',
        category: category.trim(),
        title: title.trim(),
        contentEnglish: contentEnglish.trim(),
        contentArabic: contentArabic?.trim(),
        videoUrl: videoUrl?.trim(),
        fileUrl: fileUrl?.trim(),
        imageUrl: imageUrl.trim(),
      );

      final tutorialId = await _firestoreService.createTutorial(tutorial);
      return tutorialId;
    } catch (e) {
      return null;
    }
  }

  static const List<String> validCategories = [
    'formula_mixes',
    'medication',
    'post_op_care',
    'general',
  ];
}
