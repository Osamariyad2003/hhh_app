import '../models/patient_model.dart';
import 'firebase/firestore_patient_service.dart';
import 'firebase_auth_service.dart';

class PatientService {
  PatientService._();
  static final PatientService instance = PatientService._();

  final _firestoreService = FirestorePatientService();
  final _authService = FirebaseAuthService.instance;

  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 10,
    String sortBy = 'dateOfBirth',
    String sortOrder = 'desc',
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      List<PatientModel> patients;
      try {
        patients = await _firestoreService.getPatientsByUserId(currentUserId).first;
        if (patients.isEmpty) {
          final userProfile = await _authService.getCurrentUserProfile();
        }
      } catch (e) {
        patients = [];
      }

      patients.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case 'dateOfBirth':
            comparison = a.dateOfBirth.compareTo(b.dateOfBirth);
            break;
          case 'firstName':
            comparison = a.firstName.compareTo(b.firstName);
            break;
          case 'lastName':
            comparison = a.lastName.compareTo(b.lastName);
            break;
          default:
            comparison = a.id.compareTo(b.id);
        }
        return sortOrder == 'desc' ? -comparison : comparison;
      });

      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedPatients = patients.length > startIndex
          ? patients.sublist(
              startIndex,
              endIndex > patients.length ? patients.length : endIndex,
            )
          : <PatientModel>[];

      return {
        'patients': paginatedPatients.map((p) => p.toJson()).toList(),
        'pagination': {
          'page': page,
          'limit': limit,
          'total': patients.length,
          'totalPages': (patients.length / limit).ceil(),
        },
      };
    } catch (e) {
      return {
        'patients': [],
        'pagination': {
          'page': page,
          'limit': limit,
          'total': 0,
          'totalPages': 0,
        },
        'error': e.toString(),
      };
    }
  }

  Future<List<Map<String, dynamic>>> getMyPatients() async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final patients = await _firestoreService.getPatientsByUserId(currentUserId).first;
      return patients.map((p) => p.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamMyPatients() {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestoreService.getPatientsByUserId(currentUserId).map(
      (patients) => patients.map((p) => p.toJson()).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (query.trim().isEmpty) {
        return [];
      }

      final allPatients = await _firestoreService
          .getPatientsByUserId(currentUserId)
          .first;

      final filtered = allPatients.where((p) {
        final parentName = p.parentName.toLowerCase();
        return parentName.contains(query.trim().toLowerCase());
      }).toList();

      return filtered.map((p) => p.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final patient = await _firestoreService.getPatient(patientId);
      if (patient == null) return null;
      
      if (patient.userId != currentUserId) {
        throw Exception('You can only access your own patient records');
      }
      
      return patient.toJson();
    } catch (e) {
      return null;
    }
  }

  Future<String?> createPatient({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String parentName,
    required String parentPhone,
    String? diagnoses,
    String? healthTracking,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final patient = PatientModel(
        id: '',
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        dateOfBirth: dateOfBirth,
        parentName: parentName.trim(),
        parentPhone: parentPhone.trim(),
        diagnoses: diagnoses?.trim(),
        healthTracking: healthTracking?.trim(),
        userId: currentUserId,
      );

      final patientId = await _firestoreService.createPatient(patient);
      return patientId;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePatient({
    required String patientId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? parentName,
    String? parentPhone,
    String? diagnoses,
    String? healthTracking,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final existingPatient = await _firestoreService.getPatient(patientId);
      if (existingPatient == null) {
        throw Exception('Patient not found');
      }

      if (existingPatient.userId != currentUserId) {
        throw Exception('You can only update your own patient records');
      }

      final updatedPatient = existingPatient.copyWith(
        firstName: firstName?.trim(),
        lastName: lastName?.trim(),
        dateOfBirth: dateOfBirth,
        parentName: parentName?.trim(),
        parentPhone: parentPhone?.trim(),
        diagnoses: diagnoses?.trim(),
        healthTracking: healthTracking?.trim(),
      );

      await _firestoreService.updatePatient(patientId, updatedPatient);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePatient(String patientId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final existingPatient = await _firestoreService.getPatient(patientId);
      if (existingPatient == null) {
        throw Exception('Patient not found');
      }

      if (existingPatient.userId != currentUserId) {
        throw Exception('You can only delete your own patient records');
      }

      await _firestoreService.deletePatient(patientId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
