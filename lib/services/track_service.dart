import 'dart:async';
import '../core/dio_helper.dart';
import '../services/auth_service.dart';

class TrackService {
  TrackService._();
  static final TrackService instance = TrackService._();

  String get _uid {
    final uid = AuthService.instance.currentUserId;
    if (uid == null) {
      throw StateError('User not signed in');
    }
    return uid;
  }

  String? get _token => AuthService.instance.currentToken;

  // ------------------------
  // Children
  // ------------------------

  Future<List<Map<String, dynamic>>> getChildren() async {
    try {
      final response = await DioHelper.getData(
        url: 'users/$_uid/children',
        token: _token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('children')) {
          return (data['children'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> childrenStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) => getChildren())
        .asyncMap((future) => future);
  }

  Future<Map<String, dynamic>?> getChild(String childId) async {
    try {
      final response = await DioHelper.getData(
        url: 'users/$_uid/children/$childId',
        token: _token,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> childStream(String childId) {
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
    final data = {
      'name': name.trim(),
      'dob': dob.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'archived': archived,
      if (sex != null && sex.trim().isNotEmpty) 'sex': sex.trim(),
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await DioHelper.postData(
      url: 'users/$_uid/children',
      data: data,
      token: _token,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data as Map<String, dynamic>;
      return responseData['id'] as String? ?? responseData['_id'] as String? ?? '';
    }
    throw Exception('Failed to add child: ${response.statusCode}');
  }

  Future<void> updateChild({
    required String childId,
    String? name,
    DateTime? dob,
    bool? archived,
    String? sex,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name.trim();
    if (dob != null) data['dob'] = dob.toIso8601String();
    if (archived != null) data['archived'] = archived;
    if (sex != null) data['sex'] = sex.trim().isEmpty ? null : sex.trim();
    if (notes != null) data['notes'] = notes.trim().isEmpty ? null : notes.trim();

    await DioHelper.putData(
      url: 'users/$_uid/children/$childId',
      data: data,
      token: _token,
    );
  }

  Future<void> setChildArchived({required String childId, required bool archived}) {
    return updateChild(childId: childId, archived: archived);
  }

  Future<void> deleteChild({required String childId}) async {
    await DioHelper.deleteData(
      url: 'users/$_uid/children/$childId',
      token: _token,
    );
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
