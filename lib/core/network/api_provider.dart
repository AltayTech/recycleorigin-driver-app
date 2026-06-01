import 'package:flutter/foundation.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';

/// Shared [ApiClient] for the driver app (JWT from secure storage).
class ApiProvider {
  ApiProvider._();

  static ApiClient? _client;

  static ApiClient get client => _client ??= ApiClient();

  /// Wires [onUnauthorized] before the first API call (e.g. from [AuthBloc]).
  static void init({required VoidCallback onUnauthorized}) {
    _client = ApiClient(onUnauthorized: onUnauthorized);
  }

  static void reset() {
    _client = null;
  }
}
