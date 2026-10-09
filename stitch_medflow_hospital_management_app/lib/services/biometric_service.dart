import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _passKey = 'medflow_device_pass';

  static Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('BiometricService: availability check failed: $e');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Verify your identity to enter MedFlow',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('BiometricService: authenticate failed: $e');
      return false;
    }
  }

  static Future<void> saveSession(String devicePass) async {
    try {
      await _storage.write(key: _passKey, value: devicePass);
      debugPrint('BiometricService: device pass saved (secure storage)');
    } catch (e) {
      debugPrint('BiometricService: SAVE FAILED: $e');
    }
  }

  static Future<String?> readToken() async {
    try {
      final pass = await _storage.read(key: _passKey);
      debugPrint('BiometricService: device pass read -> ${pass == null ? "null" : "found"}');
      return pass;
    } catch (e) {
      debugPrint('BiometricService: READ FAILED: $e');
      return null;
    }
  }

  static Future<void> clearSession() async {
    try {
      await _storage.delete(key: _passKey);
    } catch (e) {
      debugPrint('BiometricService: clear failed: $e');
    }
  }
}