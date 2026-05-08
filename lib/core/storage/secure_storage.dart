import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for sensitive data (access token, refresh token, profile).
///
/// Uses platform secure storage (Keychain on iOS, KeyStore on Android).
///
/// Storage keys:
///   - `accessToken`: short-lived backend JWT (15 minutes by default).
///   - `refreshToken`: opaque rotating refresh token (30 days by default).
///   - `token`: legacy alias for the access token, mirrored on every write.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyLegacyToken = 'token';
  static const _keyUserData = 'userData';
  static const _keyIsLogin = 'isLogin';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
    await _storage.write(key: _keyLegacyToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    final value = await _storage.read(key: _keyAccessToken);
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return _storage.read(key: _keyLegacyToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  /// Legacy alias for [saveAccessToken].
  static Future<void> saveToken(String token) => saveAccessToken(token);

  /// Legacy alias for [getAccessToken].
  static Future<String?> getToken() => getAccessToken();

  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyLegacyToken);
  }

  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _keyUserData, value: userData);
  }

  static Future<String?> getUserData() async {
    return _storage.read(key: _keyUserData);
  }

  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _storage.write(key: _keyIsLogin, value: isLoggedIn.toString());
  }

  static Future<bool> getLoginStatus() async {
    final status = await _storage.read(key: _keyIsLogin);
    return status == 'true';
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
