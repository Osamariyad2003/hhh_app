import 'dart:async';
import '../core/dio_helper.dart';
import '../services/firebase_auth_service.dart';
import '../services/patient_service.dart';

class TrackService {
  TrackService._();
  static final TrackService instance = TrackService._();

  final _patientService = PatientService.instance;
  final _authService = FirebaseAuthService.instance;

  String? get _uid => _authService.currentUserId;
  String? get _token => null; // No longer using REST API tokens, using Firebase

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
    try {
      final response = await DioHelper.getData(
        url: 'users/$_uid/children/$childId/weights',
        query: {
          'descending': descending,
          'limit': limit,
        },
        token: _token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('weights')) {
          return (data['weights'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> weightsStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getWeights(childId, descending: descending, limit: limit),
    ).asyncMap((future) => future);
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

    await DioHelper.postData(
      url: 'users/$_uid/children/$childId/weights',
      data: data,
      token: _token,
    );
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
    final data = <String, dynamic>{
      'valueKg': valueKg,
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (unit != null) data['unit'] = unit;
    if (clothes != null) data['clothes'] = clothes.trim().isEmpty ? null : clothes.trim();

    await DioHelper.putData(
      url: 'users/$_uid/children/$childId/weights/$logId',
      data: data,
      token: _token,
    );
  }

  Future<void> deleteWeight({required String childId, required String logId}) async {
    await DioHelper.deleteData(
      url: 'users/$_uid/children/$childId/weights/$logId',
      token: _token,
    );
  }

  // ------------------------
  // Feedings
  // ------------------------

  Future<List<Map<String, dynamic>>> getFeedings(
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: 'users/$_uid/children/$childId/feedings',
        query: {
          'descending': descending,
          'limit': limit,
        },
        token: _token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('feedings')) {
          return (data['feedings'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> feedingsStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getFeedings(childId, descending: descending, limit: limit),
    ).asyncMap((future) => future);
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

    await DioHelper.postData(
      url: 'users/$_uid/children/$childId/feedings',
      data: data,
      token: _token,
    );
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
    final data = <String, dynamic>{
      'amountMl': amountMl,
      'type': type.trim(),
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (unit != null) data['unit'] = unit;
    if (method != null) data['method'] = method.trim().isEmpty ? null : method.trim();

    await DioHelper.putData(
      url: 'users/$_uid/children/$childId/feedings/$logId',
      data: data,
      token: _token,
    );
  }

  Future<void> deleteFeeding({required String childId, required String logId}) async {
    await DioHelper.deleteData(
      url: 'users/$_uid/children/$childId/feedings/$logId',
      token: _token,
    );
  }

  // ------------------------
  // Oxygen
  // ------------------------

  Future<List<Map<String, dynamic>>> getOxygen(
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: 'users/$_uid/children/$childId/oxygen',
        query: {
          'descending': descending,
          'limit': limit,
        },
        token: _token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('oxygen')) {
          return (data['oxygen'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> oxygenStream(
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getOxygen(childId, descending: descending, limit: limit),
    ).asyncMap((future) => future);
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

    await DioHelper.postData(
      url: 'users/$_uid/children/$childId/oxygen',
      data: data,
      token: _token,
    );
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
    final data = <String, dynamic>{
      'spo2': spo2,
    };

    if (note != null) data['note'] = note.trim().isEmpty ? null : note.trim();
    if (ts != null) data['ts'] = ts.toIso8601String();
    if (source != null) data['source'] = source;
    if (pulse != null) data['pulse'] = pulse;
    if (device != null) data['device'] = device.trim().isEmpty ? null : device.trim();

    await DioHelper.putData(
      url: 'users/$_uid/children/$childId/oxygen/$logId',
      data: data,
      token: _token,
    );
  }

  Future<void> deleteOxygen({required String childId, required String logId}) async {
    await DioHelper.deleteData(
      url: 'users/$_uid/children/$childId/oxygen/$logId',
      token: _token,
    );
  }
}
