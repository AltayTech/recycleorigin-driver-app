import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for sensitive data (token, login status).
///
/// Uses platform secure storage (Keychain on iOS, KeyStore on Android).
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyToken = 'token';
  static const _keyUserData = 'userData';
  static const _keyIsLogin = 'isLogin';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
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
