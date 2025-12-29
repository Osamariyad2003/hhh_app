import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/static_childcare_data.dart';

/// Service for General Childcare Information
/// Provides access to static childcare information
class GeneralChildcareService {
  GeneralChildcareService._();
  static final GeneralChildcareService instance = GeneralChildcareService._();

  /// Stream all active childcare items, filtered by language and category
  /// Returns a stream of maps for easy consumption in UI
  Stream<List<Map<String, dynamic>>> streamChildcareItems({
    String? language,
    String? category,
  }) {
    // Load data from static_childcare_data.dart
    final items = StaticChildcareData.getItems(
      language: language,
      category: category,
    );
    
    final jsonItems = items.map((item) => item.toJson()).toList();
    
    if (kDebugMode) {
      debugPrint('Loaded ${jsonItems.length} childcare items from static data (language: $language, category: $category)');
    }
    
    // Return as immediate stream
    return Stream.value(jsonItems);
  }

  /// Get childcare item by ID
  Future<Map<String, dynamic>?> getChildcareItem(String itemId) async {
    try {
      final item = StaticChildcareData.getItemById(itemId);
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
      final items = StaticChildcareData.getItems(
        language: language,
        category: category,
      );
      return items.map((item) => item.toJson()).toList();
    } catch (e) {
      return [];
    }
  }
}

