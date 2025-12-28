import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore service for tracking data (weights, feedings, oxygen)
class FirestoreTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convert ISO8601 string to Timestamp
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

  /// Convert Timestamp to ISO8601 string
  String _timestampToString(Timestamp ts) {
    return ts.toDate().toIso8601String();
  }

  // Collection paths
  String _weightsCollection(String userId, String childId) =>
      'users/$userId/children/$childId/weights';
  String _feedingsCollection(String userId, String childId) =>
      'users/$userId/children/$childId/feedings';
  String _oxygenCollection(String userId, String childId) =>
      'users/$userId/children/$childId/oxygen';

  // ------------------------
  // Weights
  // ------------------------

  /// Get weights for a child
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
      // If index error, try without orderBy and sort manually
      try {
        final snapshot = await _firestore
            .collection(_weightsCollection(userId, childId))
            .limit(limit)
            .get();
        final docs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
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

  /// Stream weights for a child
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

  /// Add weight entry
  Future<String> addWeight(
    String userId,
    String childId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Convert ts string to Timestamp for proper Firestore ordering
      final dataCopy = Map<String, dynamic>.from(data);
      if (dataCopy['ts'] is String) {
        try {
          final dt = DateTime.parse(dataCopy['ts'] as String);
          dataCopy['ts'] = Timestamp.fromDate(dt);
        } catch (e) {
          // Keep as string if parsing fails
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

  /// Update weight entry
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
          // Keep as string if parsing fails
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

  /// Delete weight entry
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

  /// Get feedings for a child
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
          final data = doc.data() as Map<String, dynamic>;
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

  /// Stream feedings for a child
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
              final data = doc.data() as Map<String, dynamic>;
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

  /// Add feeding entry
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
          // Keep as string if parsing fails
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

  /// Update feeding entry
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
          // Keep as string if parsing fails
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

  /// Delete feeding entry
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

  /// Get oxygen readings for a child
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
          final data = doc.data() as Map<String, dynamic>;
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

  /// Stream oxygen readings for a child
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
              final data = doc.data() as Map<String, dynamic>;
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

  /// Add oxygen entry
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
          // Keep as string if parsing fails
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

  /// Update oxygen entry
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
          // Keep as string if parsing fails
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

  /// Delete oxygen entry
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

