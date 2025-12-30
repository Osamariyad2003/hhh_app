import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timestamp? _parseTimestamp(dynamic ts) {
    if (ts == null) return null;
    if (ts is Timestamp) return ts;
    if (ts is String) {
      try {
        final dt = DateTime.parse(ts);
        return Timestamp.fromDate(dt);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String _timestampToString(Timestamp ts) {
    return ts.toDate().toIso8601String();
  }

  String _weightsCollection(String userId, String childId) =>
      'users/$userId/children/$childId/weights';
  String _feedingsCollection(String userId, String childId) =>
      'users/$userId/children/$childId/feedings';
  String _oxygenCollection(String userId, String childId) =>
      'users/$userId/children/$childId/oxygen';

  // ------------------------
  // Weights
  // ------------------------

  Future<List<Map<String, dynamic>>> getWeights(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    try {
      Query query = _firestore.collection(_weightsCollection(userId, childId));
      query = query.orderBy('ts', descending: descending);
      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['ts'] is Timestamp) {
          data['ts'] = _timestampToString(data['ts'] as Timestamp);
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(_weightsCollection(userId, childId))
            .limit(limit)
            .get();
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          if (data['ts'] is Timestamp) {
            data['ts'] = _timestampToString(data['ts'] as Timestamp);
          }
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        docs.sort((a, b) {
          final aTs = a['ts'] as String? ?? '';
          final bTs = b['ts'] as String? ?? '';
          return descending ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
        });
        return docs;
      } catch (e2) {
        return [];
      }
    }
  }

  Stream<List<Map<String, dynamic>>> weightsStream(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    Query query = _firestore.collection(_weightsCollection(userId, childId));
    query = query.orderBy('ts', descending: descending);
    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    });
  }

  Future<String> addWeight(
    String userId,
    String childId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      final docRef = await _firestore
          .collection(_weightsCollection(userId, childId))
          .add(dataCopy);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add weight: $e');
    }
  }

  Future<void> updateWeight(
    String userId,
    String childId,
    String logId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      await _firestore
          .collection(_weightsCollection(userId, childId))
          .doc(logId)
          .update(dataCopy);
    } catch (e) {
      throw Exception('Failed to update weight: $e');
    }
  }

  Future<void> deleteWeight(
    String userId,
    String childId,
    String logId,
  ) async {
    try {
      await _firestore
          .collection(_weightsCollection(userId, childId))
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete weight: $e');
    }
  }

  // ------------------------
  // Feedings
  // ------------------------

  Future<List<Map<String, dynamic>>> getFeedings(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    try {
      Query query = _firestore.collection(_feedingsCollection(userId, childId));
      query = query.orderBy('ts', descending: descending);
      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['ts'] is Timestamp) {
          data['ts'] = _timestampToString(data['ts'] as Timestamp);
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(_feedingsCollection(userId, childId))
            .limit(limit)
            .get();
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          if (data['ts'] is Timestamp) {
            data['ts'] = _timestampToString(data['ts'] as Timestamp);
          }
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        docs.sort((a, b) {
          final aTs = a['ts'] as String? ?? '';
          final bTs = b['ts'] as String? ?? '';
          return descending ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
        });
        return docs;
      } catch (e2) {
        return [];
      }
    }
  }

  Stream<List<Map<String, dynamic>>> feedingsStream(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    try {
      Query query = _firestore.collection(_feedingsCollection(userId, childId));
      query = query.orderBy('ts', descending: descending);
      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['ts'] is Timestamp) {
            data['ts'] = _timestampToString(data['ts'] as Timestamp);
          }
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      }).handleError((error) {
        if (error.toString().contains('index')) {
          return _firestore
              .collection(_feedingsCollection(userId, childId))
              .limit(limit)
              .snapshots()
              .map((snapshot) {
            final docs = snapshot.docs.map((doc) {
              final data = doc.data();
              if (data['ts'] is Timestamp) {
                data['ts'] = _timestampToString(data['ts'] as Timestamp);
              }
              return {
                'id': doc.id,
                ...data,
              };
            }).toList();
            docs.sort((a, b) {
              final aTs = a['ts'] as String? ?? '';
              final bTs = b['ts'] as String? ?? '';
              return descending ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
            });
            return docs;
          });
        }
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<String> addFeeding(
    String userId,
    String childId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      final docRef = await _firestore
          .collection(_feedingsCollection(userId, childId))
          .add(dataCopy);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add feeding: $e');
    }
  }

  Future<void> updateFeeding(
    String userId,
    String childId,
    String logId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      await _firestore
          .collection(_feedingsCollection(userId, childId))
          .doc(logId)
          .update(dataCopy);
    } catch (e) {
      throw Exception('Failed to update feeding: $e');
    }
  }

  Future<void> deleteFeeding(
    String userId,
    String childId,
    String logId,
  ) async {
    try {
      await _firestore
          .collection(_feedingsCollection(userId, childId))
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete feeding: $e');
    }
  }

  // ------------------------
  // Oxygen
  // ------------------------

  Future<List<Map<String, dynamic>>> getOxygen(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) async {
    try {
      Query query = _firestore.collection(_oxygenCollection(userId, childId));
      query = query.orderBy('ts', descending: descending);
      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['ts'] is Timestamp) {
          data['ts'] = _timestampToString(data['ts'] as Timestamp);
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(_oxygenCollection(userId, childId))
            .limit(limit)
            .get();
        final docs = snapshot.docs.map((doc) {
          final data = doc.data();
          if (data['ts'] is Timestamp) {
            data['ts'] = _timestampToString(data['ts'] as Timestamp);
          }
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        docs.sort((a, b) {
          final aTs = a['ts'] as String? ?? '';
          final bTs = b['ts'] as String? ?? '';
          return descending ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
        });
        return docs;
      } catch (e2) {
        return [];
      }
    }
  }

  Stream<List<Map<String, dynamic>>> oxygenStream(
    String userId,
    String childId, {
    required bool descending,
    int limit = 200,
  }) {
    try {
      Query query = _firestore.collection(_oxygenCollection(userId, childId));
      query = query.orderBy('ts', descending: descending);
      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['ts'] is Timestamp) {
            data['ts'] = _timestampToString(data['ts'] as Timestamp);
          }
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      }).handleError((error) {
        if (error.toString().contains('index')) {
          return _firestore
              .collection(_oxygenCollection(userId, childId))
              .limit(limit)
              .snapshots()
              .map((snapshot) {
            final docs = snapshot.docs.map((doc) {
              final data = doc.data();
              if (data['ts'] is Timestamp) {
                data['ts'] = _timestampToString(data['ts'] as Timestamp);
              }
              return {
                'id': doc.id,
                ...data,
              };
            }).toList();
            docs.sort((a, b) {
              final aTs = a['ts'] as String? ?? '';
              final bTs = b['ts'] as String? ?? '';
              return descending ? bTs.compareTo(aTs) : aTs.compareTo(bTs);
            });
            return docs;
          });
        }
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<String> addOxygen(
    String userId,
    String childId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      final docRef = await _firestore
          .collection(_oxygenCollection(userId, childId))
          .add(dataCopy);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add oxygen: $e');
    }
  }

  Future<void> updateOxygen(
    String userId,
    String childId,
    String logId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
        }
      }
      
      await _firestore
          .collection(_oxygenCollection(userId, childId))
          .doc(logId)
          .update(dataCopy);
    } catch (e) {
      throw Exception('Failed to update oxygen: $e');
    }
  }

  Future<void> deleteOxygen(
    String userId,
    String childId,
    String logId,
  ) async {
    try {
      await _firestore
          .collection(_oxygenCollection(userId, childId))
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete oxygen: $e');
    }
  }
}

