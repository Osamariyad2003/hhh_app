import 'dart:async';
import '../services/firebase_auth_service.dart';
import '../services/patient_service.dart';
import 'firebase/firestore_tracking_service.dart';

class TrackService {
  TrackService._();
  static final TrackService instance = TrackService._();

  final _patientService = PatientService.instance;
  final _authService = FirebaseAuthService.instance;
  final _trackingService = FirestoreTrackingService();

  String? get _uid => _authService.currentUserId;

  // ------------------------
  // Children
  // ------------------------

  Future<List<Map<String, dynamic>>> getChildren() async {
    try {
      final patientsData = await _patientService.getMyPatients();
      // Convert PatientModel JSON to child format
      return patientsData.map((p) {
        final firstName = p['firstName'] ?? '';
        final lastName = p['lastName'] ?? '';
        final name = '$firstName $lastName'.trim();
        final healthTracking = p['healthTracking']?.toString() ?? '';
        final sex = healthTracking.contains('Sex:') 
            ? healthTracking.split('Sex:')[1].trim() 
            : 'unspecified';
        return {
          'id': p['id'],
          'name': name,
          'dob': p['dateOfBirth'],
          'sex': sex,
          'notes': p['diagnoses'],
          'archived': false,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> childrenStream() {
    return _patientService.streamMyPatients().map((patients) {
      return patients.map((p) {
        final firstName = p['firstName'] ?? '';
        final lastName = p['lastName'] ?? '';
        final name = '$firstName $lastName'.trim();
        final healthTracking = p['healthTracking']?.toString() ?? '';
        final sex = healthTracking.contains('Sex:') 
            ? healthTracking.split('Sex:')[1].trim() 
            : 'unspecified';
        return {
          'id': p['id'],
          'name': name,
          'dob': p['dateOfBirth'],
          'sex': sex,
          'notes': p['diagnoses'],
          'archived': false,
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getChild(String childId) async {
    try {
      final patient = await _patientService.getPatientById(childId);
      if (patient == null) return null;
      
      // Convert PatientModel JSON to child format
      final firstName = patient['firstName'] ?? '';
      final lastName = patient['lastName'] ?? '';
      final name = '$firstName $lastName'.trim();
      final healthTracking = patient['healthTracking']?.toString() ?? '';
      final sex = healthTracking.contains('Sex:')
          ? healthTracking.split('Sex:')[1].trim()
          : 'unspecified';
      
      return {
        'id': patient['id'],
        'name': name,
        'dob': patient['dateOfBirth'],
        'sex': sex,
        'notes': patient['diagnoses'],
        'archived': false,
      };
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> childStream(String childId) {
    // Note: PatientService doesn't have a stream for single patient
    // So we'll use periodic polling
    return Stream.periodic(const Duration(seconds: 5), (_) => getChild(childId))
        .asyncMap((future) => future);
  }

  Future<String> addChild({
    required String name,
    required DateTime dob,
    bool archived = false,
    String? sex,
    String? notes,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    // Split name into first and last name
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : name.trim();
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Get parent info from current user
    final userProfile = await _authService.getCurrentUserProfile();
    final parentName = userProfile?.username ?? 'Parent';
    final parentPhone = ''; // Can be added to user profile later

    // Create patient (child) using PatientService
    final patientId = await _patientService.createPatient(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dob,
      parentName: parentName,
      parentPhone: parentPhone,
      diagnoses: notes?.trim().isNotEmpty == true ? notes : null,
      healthTracking: sex?.trim().isNotEmpty == true ? 'Sex: $sex' : null,
    );

    if (patientId == null) {
      throw Exception('Failed to create child');
    }

    return patientId;
  }

  Future<void> updateChild({
    required String childId,
    String? name,
    DateTime? dob,
    bool? archived,
    String? sex,
    String? notes,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    // Split name if provided
    String? firstName;
    String? lastName;
    if (name != null && name.trim().isNotEmpty) {
      final nameParts = name.trim().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : name.trim();
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    // Update using PatientService
    await _patientService.updatePatient(
      patientId: childId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dob,
      diagnoses: notes?.trim().isNotEmpty == true ? notes : null,
      healthTracking: sex?.trim().isNotEmpty == true ? 'Sex: $sex' : null,
    );
  }

  Future<void> setChildArchived({required String childId, required bool archived}) {
    // Note: Archived functionality not yet implemented in PatientService
    // For now, we'll just return without error
    return Future.value();
  }

  Future<void> deleteChild({required String childId}) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    await _patientService.deletePatient(childId);
  }

  // ------------------------
  // Weights
  // ------------------------

  Future<List<Map<String, dynamic>>> getWeights(
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    if (_uid == null) return [];
    return await _trackingService.getWeights(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Stream<List<Map<String, dynamic>>> weightsStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    if (_uid == null) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
    return _trackingService.weightsStream(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Future<void> addWeight({
    required String childId,
    required double valueKg,
    String? note,
    DateTime? ts,
    String source = 'manual',
    String unit = 'kg',
    String? clothes,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final when = ts ?? DateTime.now();
    final data = {
      'valueKg': valueKg,
      'ts': when.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'source': source,
      'unit': unit,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (clothes != null && clothes.trim().isNotEmpty) 'clothes': clothes.trim(),
    };

    await _trackingService.addWeight(_uid!, childId, data);
  }

  Future<void> updateWeight({
    required String childId,
    required String logId,
    required double valueKg,
    String? note,
    DateTime? ts,
    String? source,
    String? unit,
    String? clothes,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final data = <String, dynamic>{
      'valueKg': valueKg,
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (unit != null) data['unit'] = unit;
    if (clothes != null) data['clothes'] = clothes.trim().isEmpty ? null : clothes.trim();

    await _trackingService.updateWeight(_uid!, childId, logId, data);
  }

  Future<void> deleteWeight({required String childId, required String logId}) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }
    await _trackingService.deleteWeight(_uid!, childId, logId);
  }

  // ------------------------
  // Feedings
  // ------------------------

  Future<List<Map<String, dynamic>>> getFeedings(
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    if (_uid == null) return [];
    return await _trackingService.getFeedings(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Stream<List<Map<String, dynamic>>> feedingsStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    if (_uid == null) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
    return _trackingService.feedingsStream(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Future<void> addFeeding({
    required String childId,
    required double amountMl,
    required String type,
    String? note,
    DateTime? ts,
    String source = 'manual',
    String unit = 'ml',
    String? method,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final when = ts ?? DateTime.now();
    final data = {
      'amountMl': amountMl,
      'type': type.trim(),
      'ts': when.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'source': source,
      'unit': unit,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (method != null && method.trim().isNotEmpty) 'method': method.trim(),
    };

    await _trackingService.addFeeding(_uid!, childId, data);
  }

  Future<void> updateFeeding({
    required String childId,
    required String logId,
    required double amountMl,
    required String type,
    String? note,
    DateTime? ts,
    String? source,
    String? unit,
    String? method,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final data = <String, dynamic>{
      'amountMl': amountMl,
      'type': type.trim(),
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (unit != null) data['unit'] = unit;
    if (method != null) data['method'] = method.trim().isEmpty ? null : method.trim();

    await _trackingService.updateFeeding(_uid!, childId, logId, data);
  }

  Future<void> deleteFeeding({required String childId, required String logId}) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }
    await _trackingService.deleteFeeding(_uid!, childId, logId);
  }

  // ------------------------
  // Oxygen
  // ------------------------

  Future<List<Map<String, dynamic>>> getOxygen(
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    if (_uid == null) return [];
    return await _trackingService.getOxygen(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Stream<List<Map<String, dynamic>>> oxygenStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    if (_uid == null) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
    return _trackingService.oxygenStream(
      _uid!,
      childId,
      descending: descending,
      limit: limit,
    );
  }

  Future<void> addOxygen({
    required String childId,
    required int spo2,
    String? note,
    DateTime? ts,
    String source = 'manual',
    int? pulse,
    String? device,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final when = ts ?? DateTime.now();
    final data = {
      'spo2': spo2,
      'ts': when.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'source': source,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (pulse != null) 'pulse': pulse,
      if (device != null && device.trim().isNotEmpty) 'device': device.trim(),
    };

    await _trackingService.addOxygen(_uid!, childId, data);
  }

  Future<void> updateOxygen({
    required String childId,
    required String logId,
    required int spo2,
    String? note,
    DateTime? ts,
    String? source,
    int? pulse,
    String? device,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final data = <String, dynamic>{
      'spo2': spo2,
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (pulse != null) data['pulse'] = pulse;
    if (device != null) data['device'] = device.trim().isEmpty ? null : device.trim();

    await _trackingService.updateOxygen(_uid!, childId, logId, data);
  }

  Future<void> deleteOxygen({required String childId, required String logId}) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }
    await _trackingService.deleteOxygen(_uid!, childId, logId);
  }
}
