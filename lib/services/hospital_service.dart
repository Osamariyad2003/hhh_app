import '../models/hospital_model.dart';
import 'firebase/firestore_hospital_service.dart';

class HospitalService {
  HospitalService._();
  static final HospitalService instance = HospitalService._();

  final _firestoreService = FirestoreHospitalService();

  /// Get all hospitals
  Future<List<Map<String, dynamic>>> getHospitals() async {
    try {
      final hospitals = await _firestoreService.getAllHospitals().first;
      return hospitals.map((h) => h.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream all hospitals
  Stream<List<Map<String, dynamic>>> streamHospitals() {
    return _firestoreService.getAllHospitals().map(
      (hospitals) => hospitals.map((h) => h.toJson()).toList(),
    );
  }

  /// Get hospital by ID
  Future<Map<String, dynamic>?> getHospital(String hospitalId) async {
    try {
      final hospital = await _firestoreService.getHospital(hospitalId);
      return hospital?.toJson();
    } catch (e) {
      return null;
    }
  }
}

