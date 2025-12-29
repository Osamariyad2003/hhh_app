import 'package:flutter/foundation.dart';
import 'firebase/firestore_general_childcare_service.dart';

/// Service for General Childcare Information
/// Provides access to childcare information from Firestore
class GeneralChildcareService {
  GeneralChildcareService._();
  static final GeneralChildcareService instance = GeneralChildcareService._();

  final _firestoreService = FirestoreGeneralChildcareService();

  /// Stream all active childcare items, filtered by language and category
  /// Returns a stream of maps for easy consumption in UI
  Stream<List<Map<String, dynamic>>> streamChildcareItems({
    String? language,
    String? category,
  }) {
    return _firestoreService
        .getChildcareItems(language: language, category: category)
        .map((items) => items.map((item) => item.toJson()).toList())
        .handleError((error) {
      // Return empty list on error to prevent stream from closing
      debugPrint('Error in streamChildcareItems: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Get childcare item by ID
  Future<Map<String, dynamic>?> getChildcareItem(String itemId) async {
    try {
      final item = await _firestoreService.getChildcareItem(itemId);
      return item?.toJson();
    } catch (e) {
      return null;
    }
  }

  /// Get all active childcare items once (for fallback)
  Future<List<Map<String, dynamic>>> getChildcareItemsOnce({
    String? language,
    String? category,
  }) async {
    try {
      final items = await _firestoreService.getChildcareItemsOnce(
        language: language,
        category: category,
      );
      return items.map((item) => item.toJson()).toList();
    } catch (e) {
      return [];
    }
  }
}

