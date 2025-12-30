import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/general_childcare_model.dart';

class FirestoreGeneralChildcareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'general_childcare';

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

  Stream<List<GeneralChildcareModel>> getChildcareItems({
    String? language,
    String? category,
  }) {
    try {
      Query query = _firestore.collection(_collection);

      query = query.where('isActive', isEqualTo: true);

      if (language != null && language.isNotEmpty) {
        query = query.where('language', isEqualTo: language);
      }

      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

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
        debugPrint('Firestore query error: $error');
        return Stream.value(<GeneralChildcareModel>[]);
      });
    } catch (e) {
      debugPrint('Firestore service error: $e');
      return Stream.value(<GeneralChildcareModel>[]);
    }
  }

  Future<List<GeneralChildcareModel>> getChildcareItemsOnce({
    String? language,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      query = query.where('isActive', isEqualTo: true);

      if (language != null && language.isNotEmpty) {
        query = query.where('language', isEqualTo: language);
      }

      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

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

        if (language != null && language.isNotEmpty) {
          items = items.where((item) => item.language == language).toList();
        }

        if (category != null && category.isNotEmpty && category != 'all') {
          items = items.where((item) => item.category == category).toList();
        }

        items.sort((a, b) => a.order.compareTo(b.order));

        return items;
      } catch (fallbackError) {
        throw Exception('Failed to get childcare items: $e');
      }
    }
  }

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

  Future<void> deleteChildcareItem(String itemId) async {
    try {
      await _firestore.collection(_collection).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete childcare item: $e');
    }
  }
}

