import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService._();
  static final AppLockService instance = AppLockService._();

  static const _kPinHash = 'pin_hash';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> hasPin() async {
    final v = await _secure.read(key: _kPinHash);
    return v != null && v.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _secure.write(key: _kPinHash, value: _hashPin(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _kPinHash);
    if (stored == null || stored.isEmpty) return false;
    return stored == _hashPin(pin);
  }

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> biometricUnlock({String localizedReason = 'Unlock the app to access your child\'s health information'}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: localizedReason,
      );
      return ok;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
