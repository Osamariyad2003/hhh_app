import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_model.dart';

/// Firestore service for Patient entity
class FirestorePatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'patients';

  /// Get patient by ID
  Future<PatientModel?> getPatient(String patientId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(patientId).get();
      if (!doc.exists) return null;
      return PatientModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get patient: $e');
    }
  }

  /// Create patient
  Future<String> createPatient(PatientModel patient) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            patient.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create patient: $e');
    }
  }

  /// Update patient
  Future<void> updatePatient(String patientId, PatientModel patient) async {
    try {
      await _firestore.collection(_collection).doc(patientId).update(
            patient.copyWith(id: patientId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete patient
  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection(_collection).doc(patientId).delete();
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  /// Get all patients
  Stream<List<PatientModel>> getAllPatients() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Search patients by parent name
  Stream<List<PatientModel>> searchPatientsByParentName(String parentName) {
    return _firestore
        .collection(_collection)
        .where('parentName', isGreaterThanOrEqualTo: parentName)
        .where('parentName', isLessThanOrEqualTo: '$parentName\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get patients by user ID (for patients/caregivers to see their own patients)
  Stream<List<PatientModel>> getPatientsByUserId(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }

  /// Get patients by parent phone (alternative way to link patients to users)
  Stream<List<PatientModel>> getPatientsByParentPhone(String parentPhone) {
    return _firestore
        .collection(_collection)
        .where('parentPhone', isEqualTo: parentPhone)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PatientModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }
}

