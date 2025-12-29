import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/general_childcare_model.dart';

/// Firestore service for General Childcare Information
/// Connects to Firebase Firestore collection: 'general_childcare'
class FirestoreGeneralChildcareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'general_childcare';

  /// Get childcare item by ID
  Future<GeneralChildcareModel?> getChildcareItem(String itemId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(itemId).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return GeneralChildcareModel.fromJson({'id': doc.id, ...data});
    } catch (e) {
      throw Exception('Failed to get childcare item: $e');
    }
  }

  /// Get all active childcare items, filtered by language and category
  /// Sorted by order field
  Stream<List<GeneralChildcareModel>> getChildcareItems({
    String? language,
    String? category,
  }) {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by isActive
      query = query.where('isActive', isEqualTo: true);

      // Filter by language if provided
      if (language != null && language.isNotEmpty) {
        query = query.where('language', isEqualTo: language);
      }

      // Filter by category if provided (and not "all")
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      // Order by order field
      query = query.orderBy('order');

      return query.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return GeneralChildcareModel.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList(),
      ).handleError((error) {
        // If query fails (e.g., missing index), try fallback
        debugPrint('Firestore query error: $error');
        // Return empty stream to prevent stream from closing
        return Stream.value(<GeneralChildcareModel>[]);
      });
    } catch (e) {
      debugPrint('Firestore service error: $e');
      // Return empty stream instead of throwing
      return Stream.value(<GeneralChildcareModel>[]);
    }
  }

  /// Get all active childcare items (for fallback when query fails)
  Future<List<GeneralChildcareModel>> getChildcareItemsOnce({
    String? language,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by isActive
      query = query.where('isActive', isEqualTo: true);

      // Filter by language if provided
      if (language != null && language.isNotEmpty) {
        query = query.where('language', isEqualTo: language);
      }

      // Filter by category if provided (and not "all")
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      // Order by order field
      query = query.orderBy('order');

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return GeneralChildcareModel.fromJson({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
    } catch (e) {
      // If query fails (e.g., missing index), fetch all and filter in memory
      try {
        final snapshot = await _firestore
            .collection(_collection)
            .where('isActive', isEqualTo: true)
            .get();

        var items = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return GeneralChildcareModel.fromJson({
                'id': doc.id,
                ...data,
              });
            })
            .toList();

        // Filter by language
        if (language != null && language.isNotEmpty) {
          items = items.where((item) => item.language == language).toList();
        }

        // Filter by category
        if (category != null && category.isNotEmpty && category != 'all') {
          items = items.where((item) => item.category == category).toList();
        }

        // Sort by order
        items.sort((a, b) => a.order.compareTo(b.order));

        return items;
      } catch (fallbackError) {
        throw Exception('Failed to get childcare items: $e');
      }
    }
  }

  /// Create childcare item
  Future<String> createChildcareItem(GeneralChildcareModel item) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            item.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create childcare item: $e');
    }
  }

  /// Update childcare item
  Future<void> updateChildcareItem(
      String itemId, GeneralChildcareModel item) async {
    try {
      await _firestore.collection(_collection).doc(itemId).update(
            item.copyWith(id: itemId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update childcare item: $e');
    }
  }

  /// Delete childcare item
  Future<void> deleteChildcareItem(String itemId) async {
    try {
      await _firestore.collection(_collection).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete childcare item: $e');
    }
  }
}

