import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/static_childcare_data.dart';

class GeneralChildcareService {
  GeneralChildcareService._();
  static final GeneralChildcareService instance = GeneralChildcareService._();

  Stream<List<Map<String, dynamic>>> streamChildcareItems({
    String? language,
    String? category,
  }) {
    final items = StaticChildcareData.getItems(
      language: language,
      category: category,
    );
    
    final jsonItems = items.map((item) => item.toJson()).toList();
    
    if (kDebugMode) {
      debugPrint('Loaded ${jsonItems.length} childcare items from static data (language: $language, category: $category)');
    }
    
    return Stream.value(jsonItems);
  }

  Future<Map<String, dynamic>?> getChildcareItem(String itemId) async {
    try {
      final item = StaticChildcareData.getItemById(itemId);
      return item?.toJson();
    } catch (e) {
      return null;
    }
  }

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

