/// Drop-in replacement for `package:http` top-level helpers that keeps the
/// driver session alive.
///
/// The backend access token expires after ~15 minutes. Requests sent with a
/// `Bearer` header that come back as 401 are retried once with the current
/// stored token (another client may have rotated it already) and, failing
/// that, after a single-flight refresh through [TokenRefresher]. When the
/// refresh token itself is rejected the refresher clears the session and
/// notifies the auth layer, and the original 401 response is returned.
///
/// Import this file instead of `package:http/http.dart` for authenticated
/// backend calls.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/network/token_refresher.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

export 'package:http/http.dart' show Response;

Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
  return _withAuthRetry(headers, (h) => http.get(url, headers: h));
}

Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _withAuthRetry(
    headers,
    (h) => http.post(url, headers: h, body: body, encoding: encoding),
  );
}

Future<http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _withAuthRetry(
    headers,
    (h) => http.put(url, headers: h, body: body, encoding: encoding),
  );
}

Future<http.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _withAuthRetry(
    headers,
    (h) => http.patch(url, headers: h, body: body, encoding: encoding),
  );
}

Future<http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _withAuthRetry(
    headers,
    (h) => http.delete(url, headers: h, body: body, encoding: encoding),
  );
}

typedef _Send = Future<http.Response> Function(Map<String, String>? headers);

Future<http.Response> _withAuthRetry(
  Map<String, String>? headers,
  _Send send,
) async {
  final response = await send(headers);
  if (response.statusCode != 401 || !_hasBearerToken(headers)) {
    return response;
  }
  // The token pair may have been rotated by another client (e.g. Dio) while
  // this request was in flight; retry with the stored token before spending
  // a refresh.
  final stored = await SecureStorage.getAccessToken() ?? '';
  if (stored.isNotEmpty && 'Bearer $stored' != headers!['Authorization']) {
    final retried = await send(_withToken(headers, stored));
    if (retried.statusCode != 401) {
      return retried;
    }
  }
  final bool refreshed;
  try {
    refreshed = await TokenRefresher.instance.refreshSession();
  } catch (_) {
    // Transient refresh failure (network, 5xx): keep the session and let the
    // caller see the original 401 so it can surface a retryable error.
    return response;
  }
  if (!refreshed) {
    return response;
  }
  final token = await SecureStorage.getAccessToken() ?? '';
  return send(_withToken(headers, token));
}

bool _hasBearerToken(Map<String, String>? headers) {
  final value = headers?['Authorization'];
  if (value == null) {
    return false;
  }
  return value.startsWith('Bearer ') && value.length > 'Bearer '.length;
}

Map<String, String> _withToken(Map<String, String>? headers, String token) {
  return Map<String, String>.from(headers ?? const {})
    ..['Authorization'] = 'Bearer $token';
}
