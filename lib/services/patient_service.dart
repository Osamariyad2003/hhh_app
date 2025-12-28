import '../models/patient_model.dart';
import 'firebase/firestore_patient_service.dart';
import 'firebase_auth_service.dart';

class PatientService {
  PatientService._();
  static final PatientService instance = PatientService._();

  final _firestoreService = FirestorePatientService();
  final _authService = FirebaseAuthService.instance;

  /// Get all patients with pagination (admins) or user's own patients
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

      // All users are parents - they can only see their own patients
      List<PatientModel> patients;
      try {
        patients = await _firestoreService.getPatientsByUserId(currentUserId).first;
        if (patients.isEmpty) {
          // Fallback: try to get user's phone number and match by parentPhone
          final userProfile = await _authService.getCurrentUserProfile();
          // Note: You may need to add phoneNumber to FirebaseUserModel
          // For now, we'll use userId matching
        }
      } catch (e) {
        patients = [];
      }

      // Sort patients
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

      // Apply pagination
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

  /// Get current user's patients (for patients/caregivers)
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

  /// Stream of current user's patients (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamMyPatients() {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestoreService.getPatientsByUserId(currentUserId).map(
      (patients) => patients.map((p) => p.toJson()).toList(),
    );
  }

  /// Search patients by parent name (parents can only search their own patients)
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (query.trim().isEmpty) {
        return [];
      }

      // Parents can only search their own patients
      final allPatients = await _firestoreService
          .getPatientsByUserId(currentUserId)
          .first;

      // Filter by parent name
      final filtered = allPatients.where((p) {
        final parentName = p.parentName.toLowerCase();
        return parentName.contains(query.trim().toLowerCase());
      }).toList();

      return filtered.map((p) => p.toJson()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get patient by ID (parents can only access their own patients)
  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final patient = await _firestoreService.getPatient(patientId);
      if (patient == null) return null;
      
      // Check if patient belongs to current user (parent)
      if (patient.userId != currentUserId) {
        throw Exception('You can only access your own patient records');
      }
      
      return patient.toJson();
    } catch (e) {
      return null;
    }
  }

  /// Create patient (parents can create their own patients)
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
        id: '', // Will be generated by Firestore
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        dateOfBirth: dateOfBirth,
        parentName: parentName.trim(),
        parentPhone: parentPhone.trim(),
        diagnoses: diagnoses?.trim(),
        healthTracking: healthTracking?.trim(),
        userId: currentUserId, // Link to current user
      );

      final patientId = await _firestoreService.createPatient(patient);
      return patientId;
    } catch (e) {
      return null;
    }
  }

  /// Update patient (parents can only update their own patients)
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

      // Check if patient belongs to current user (parent)
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

  /// Delete patient (parents can delete their own patients)
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

      // Check if patient belongs to current user (parent)
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
