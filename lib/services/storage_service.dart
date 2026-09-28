import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pashudhan_qr/app/app.logger.dart';

class StorageService {
  final _logger = getLogger('StorageService');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Key constants ─────────────────────────────────────────────────────────
  static const String _jwtTokenKey = 'auth_token';
  static const String _otpTokenKey = 'otp_token';
  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _jwtTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _jwtTokenKey);
  }

  Future<void> saveOtpToken(String token) async {
    await _secureStorage.write(key: _otpTokenKey, value: token);
  }

  Future<String?> getOtpToken() async {
    return await _secureStorage.read(key: _otpTokenKey);
  }

  Future<void> deleteOtpToken() async {
    await _secureStorage.delete(key: _otpTokenKey);
  }

  // ── Custom key-value ──────────────────────────────────────────────────────

  Future<void> saveCustomData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getCustomData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteCustomData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  Future<void> saveUserId(String id) => saveCustomData(_userIdKey, id);
  Future<String?> getUserId() => getCustomData(_userIdKey);

  Future<void> saveUserName(String name) => saveCustomData(_userNameKey, name);
  Future<String?> getUserName() => getCustomData(_userNameKey);

  Future<void> saveUserRole(String role) => saveCustomData(_userRoleKey, role);
  Future<String?> getUserRole() => getCustomData(_userRoleKey);

  Future<void> setHasSeenAppFlow(String userId, bool value) => saveCustomData('hasSeenAppFlow_${userId.toString()}', value.toString());
  Future<bool> getHasSeenAppFlow(String userId) async {
    final value = await getCustomData('hasSeenAppFlow_${userId.toString()}');
    return value == 'true';
  }

  // ── Named clear (partial) ─────────────────────────────────────────────────

  Future<void> clearAuth() async {
    await deleteToken();
    await deleteOtpToken();
    await deleteCustomData(_userNameKey);
    await deleteCustomData(_userIdKey);
    await deleteCustomData(_userRoleKey);
  }

  // ── Full wipe — MUST exist for logout ─────────────────────────────────────

  /// Deletes ALL keys from secure storage. Use on logout.
  /// Never throws — errors are caught and logged.
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      if (kDebugMode) _logger.i('StorageService: clearAll() complete.');
    } catch (e) {
      if (kDebugMode) _logger.e('StorageService: clearAll() failed: $e');
    }
  }
}
