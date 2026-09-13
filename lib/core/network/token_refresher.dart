import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// Rotates the access/refresh token pair against the backend.
///
/// Shared by the Dio `ApiClient` and the `auth_http` helpers so concurrent
/// 401s from either HTTP stack collapse into a single
/// `POST /auth/refresh` call. The backend rotates the refresh token on
/// every use, so parallel refreshes could revoke the whole session.
class TokenRefresher {
  TokenRefresher._();

  static final TokenRefresher instance = TokenRefresher._();

  /// Fired once when the session can no longer be recovered (the backend
  /// rejected the refresh token, or none is stored). The auth layer should
  /// clear in-memory state and route to the login screen.
  void Function()? onSessionExpired;

  Future<bool>? _inflight;

  /// Exchanges the stored refresh token for a new token pair.
  ///
  /// Returns `true` when new tokens were saved. Returns `false` after
  /// clearing the session when the backend permanently rejected the refresh
  /// token. Throws on transient failures (network error, 5xx); the session
  /// is kept in that case so a later attempt can still succeed.
  Future<bool> refreshSession() {
    final inflight = _inflight;
    if (inflight != null) {
      return inflight;
    }
    final future = _refresh().whenComplete(() => _inflight = null);
    _inflight = future;
    return future;
  }

  Future<bool> _refresh() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      developer.log(
        'No refresh token stored; expiring session',
        name: 'driver.auth',
        level: 900,
      );
      await expireSession();
      return false;
    }
    final uri = Uri.parse('${AppConfig.apiBaseUrl}${Urls.refreshTokenPath}');
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode == 200) {
      return _persistTokens(response.body, uri);
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      developer.log(
        'Refresh rejected (HTTP ${response.statusCode}); expiring session',
        name: 'driver.auth',
        level: 900,
      );
      await expireSession();
      return false;
    }
    throw http.ClientException(
      'Token refresh failed: HTTP ${response.statusCode}',
      uri,
    );
  }

  Future<bool> _persistTokens(String body, Uri uri) async {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw http.ClientException('Malformed refresh response', uri);
    }
    final access =
        (decoded['access_token'] ?? decoded['token']) as String? ?? '';
    final refresh = decoded['refresh_token'] as String? ?? '';
    if (access.isEmpty || refresh.isEmpty) {
      throw http.ClientException('Refresh response missing tokens', uri);
    }
    await SecureStorage.saveAccessToken(access);
    await SecureStorage.saveRefreshToken(refresh);
    return true;
  }

  /// Clears the stored session and notifies the auth layer once.
  Future<void> expireSession() async {
    await SecureStorage.deleteToken();
    await SecureStorage.saveLoginStatus(false);
    onSessionExpired?.call();
  }
}
