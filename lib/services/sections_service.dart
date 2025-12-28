import '../core/dio_helper.dart';
import '../models/section_content.dart';

class SectionsService {
  SectionsService._();
  static final SectionsService instance = SectionsService._();

  Future<SectionContent?> getSection(String sectionId) async {
    try {
      final response = await DioHelper.getData(
        url: 'content/sections/$sectionId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SectionContent.fromMap(sectionId, data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<SectionContent?> streamSection(String sectionId) {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => getSection(sectionId),
    ).asyncMap((future) => future);
  }
}
