import '../models/tutorial_item.dart';
import '../models/tutorial_model.dart';
import 'firebase/firestore_tutorial_service.dart';

class TutorialsService {
  TutorialsService._();
  static final TutorialsService instance = TutorialsService._();

  final _firestoreService = FirestoreTutorialService();

  TutorialItem _convertToTutorialItem(TutorialModel model) {
    String type = 'url';
    String? url;
    String? r2Key;

    if (model.videoUrl != null && model.videoUrl!.isNotEmpty) {
      url = model.videoUrl;
      type = 'url';
    } else if (model.fileUrl != null && model.fileUrl!.isNotEmpty) {
      url = model.fileUrl;
      type = 'url';
    } else if (model.imageUrl.isNotEmpty) {
      url = model.imageUrl;
      type = 'url';
    }

    return TutorialItem(
      id: model.id,
      type: type,
      titleEn: model.title,
      titleAr: model.title, 
      descriptionEn: model.contentEnglish,
      descriptionAr: model.contentArabic,
      url: url,
      r2Key: r2Key,
      order: null,
      enabled: true,
      category: model.category,
      updatedAt: null,
    );
  }

  Future<List<TutorialItem>> getTutorials() async {
    try {
      final tutorials = await _firestoreService.getAllTutorials().first;
      
      final items = tutorials.map(_convertToTutorialItem).toList();
      
      final enabledOnly = items.where((t) => t.enabled).toList();
      enabledOnly.sort(
        (a, b) => (a.order ?? 999999).compareTo(b.order ?? 999999),
      );

      return enabledOnly;
    } catch (e) {
      return [];
    }
  }

  Stream<List<TutorialItem>> streamTutorials() {
    return _firestoreService.getAllTutorials().map(
      (tutorials) {
        final items = tutorials.map(_convertToTutorialItem).toList();
        final enabledOnly = items.where((t) => t.enabled).toList();
        enabledOnly.sort(
          (a, b) => (a.order ?? 999999).compareTo(b.order ?? 999999),
        );
        return enabledOnly;
      },
    );
  }
}
