import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/heart_disease_prediction.dart';

/// Firestore service for Heart Disease Predictions
class FirestorePredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'predictions';

  /// Save a prediction to Firestore
  Future<String> savePrediction({
    required HeartDiseasePredictionRequest request,
    required HeartDiseasePredictionResponse response,
    String? userId,
    String? patientId,
  }) async {
    try {
      final data = {
        'request': request.toJson(),
        'response': {
          'hasDisease': response.hasDisease,
          'probability': response.probability,
          'model': response.model,
          'riskLevel': response.riskLevel,
          'recommendation': response.recommendation,
          if (response.details != null) 'details': response.details,
        },
        'userId': userId,
        'patientId': patientId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save prediction: $e');
    }
  }

  /// Get prediction by ID
  Future<Map<String, dynamic>?> getPrediction(String predictionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(predictionId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Failed to get prediction: $e');
    }
  }

  /// Get all predictions for a user
  Stream<List<Map<String, dynamic>>> getUserPredictions(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Get all predictions for a patient
  Stream<List<Map<String, dynamic>>> getPatientPredictions(String patientId) {
    return _firestore
        .collection(_collection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Get all predictions (admin only)
  Stream<List<Map<String, dynamic>>> getAllPredictions() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Delete prediction
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _firestore.collection(_collection).doc(predictionId).delete();
    } catch (e) {
      throw Exception('Failed to delete prediction: $e');
    }
  }
}

