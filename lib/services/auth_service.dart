import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _storage = const FlutterSecureStorage();
  static const _kTokenKey = 'auth_token';
  static const _kUserIdKey = 'user_id';

  String? _currentUserId;
  String? _currentToken;
  final _authStateController = StreamController<String?>.broadcast();

  Stream<String?> authStateChanges() => _authStateController.stream;

  String? get currentUserId => _currentUserId;
  String? get currentToken => _currentToken;

  Future<void> signInAnonymously() async {
    try {
      _currentUserId = 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      _currentToken = null;
      await _storage.write(key: _kUserIdKey, value: _currentUserId);
      _authStateController.add(_currentUserId);
    } catch (e) {
      _currentUserId = 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      _currentToken = null;
      await _storage.write(key: _kUserIdKey, value: _currentUserId);
      _authStateController.add(_currentUserId);
    }
  }

  Future<void> storeAuth(String token, String userId) async {
    _currentToken = token;
    _currentUserId = userId;
    await _storage.write(key: _kTokenKey, value: token);
    await _storage.write(key: _kUserIdKey, value: userId);
    _authStateController.add(userId);
  }

  Future<void> signOut() async {
    _currentUserId = null;
    _currentToken = null;
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserIdKey);
    _authStateController.add(null);
  }

  Future<void> loadStoredAuth() async {
    _currentToken = await _storage.read(key: _kTokenKey);
    _currentUserId = await _storage.read(key: _kUserIdKey);
    if (_currentUserId != null) {
      _authStateController.add(_currentUserId);
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
