import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/hospital_model.dart';

class FirestoreHospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'hospitals';

  Future<HospitalModel?> getHospital(String hospitalId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(hospitalId).get();
      if (!doc.exists) return null;
      return HospitalModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get hospital: $e');
    }
  }

  Future<String> createHospital(HospitalModel hospital) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            hospital.copyWith(id: '').toJson()..remove('id'),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create hospital: $e');
    }
  }

  Future<void> updateHospital(String hospitalId, HospitalModel hospital) async {
    try {
      await _firestore.collection(_collection).doc(hospitalId).update(
            hospital.copyWith(id: hospitalId).toJson()..remove('id'),
          );
    } catch (e) {
      throw Exception('Failed to update hospital: $e');
    }
  }

  Future<void> deleteHospital(String hospitalId) async {
    try {
      await _firestore.collection(_collection).doc(hospitalId).delete();
    } catch (e) {
      throw Exception('Failed to delete hospital: $e');
    }
  }

  Stream<List<HospitalModel>> getAllHospitals() {
    return _firestore.collection(_collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => HospitalModel.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .toList(),
        );
  }
}

