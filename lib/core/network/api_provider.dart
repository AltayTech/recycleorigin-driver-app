import 'package:flutter/foundation.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/network/token_refresher.dart';

/// Shared [ApiClient] for the driver app (JWT from secure storage).
class ApiProvider {
  ApiProvider._();

  static ApiClient? _client;

  static ApiClient get client => _client ??= ApiClient();

  /// Wires the session-expiry callback before the first API call (e.g. from
  /// `AuthBloc`). Fired by [TokenRefresher] when the refresh token is
  /// rejected and the user must log in again.
  static void init({required VoidCallback onUnauthorized}) {
    _client = ApiClient();
    TokenRefresher.instance.onSessionExpired = onUnauthorized;
  }

  static void reset() {
    _client = null;
    TokenRefresher.instance.onSessionExpired = null;
  }
}
