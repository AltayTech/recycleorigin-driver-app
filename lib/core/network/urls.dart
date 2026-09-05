import 'package:recycleorigindriver/core/config/app_config.dart';

/// API URL constants. Same auth contract as main Recycle Origin app (JWT).
class Urls {
  /// Base URL for the backend (no trailing path).
  /// Local: Android emulator uses 10.0.2.2 to reach host; physical device use your PC IP (e.g. http://192.168.1.100:8080/).
  /// Production: use https://recycleorigin.com/
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  /// REST API root (recycleorigin v1). Full URL for `package:http` callers.
  static String get rootUrl => '${apiBaseUrl}recycleorigin/v1';

  /// Path prefix relative to [apiBaseUrl] for Dio (do not include the host).
  static const String v1Path = 'recycleorigin/v1';

  static const wastesEndPoint = '/wastes';
  static const addressEndPoint = '/customer/address';
  static const regionEndPoint = '/customer/regions';
  static const collectsEndPoint = '/collects';

  /// Collects assigned to the logged-in driver (use this in driver app for "my requests").
  static const driverCollectsEndPoint = '/driver/collects';

  /// POST `{ "score": 1-5, "comment": "optional" }` after pickup.
  static String driverCollectRatePath(int collectId) =>
      '$driverCollectsEndPoint/$collectId/rate';
  static const checkCompletedEndPoint = '/customer/completed';
  static const driverEndPoint = '/driver';

  /// Dio paths relative to [apiBaseUrl]. Passing [rootUrl] here concatenates
  /// the host twice because [ApiClient] already sets Dio `baseUrl`.
  static String get driverRouteToday => '$v1Path/driver/route/today';

  static String get driverRouteRebuild => '$v1Path/driver/route/rebuild';

  static String get driverLocation => '$v1Path/driver/location';

  static String driverRouteStopAction(int stopId, String action) =>
      '$v1Path/driver/route/stops/$stopId/$action';
  static const deliveriesEndPoint = '/deliveries';
  static const clearingEndPoint = '/clearings';
  static const transactionsEndPoint = '/transactions';
  static const walletEndPoint = '/wallet';
  static const walletTransactionsEndPoint = '/wallet/transactions';
  static const walletWithdrawEndPoint = '/wallet/withdraw';
  static const statsImpactEndPoint = '/stats/impact';
  static const statsLeaderboardEndPoint = '/stats/leaderboard';
  static const provincesEndPoint = '/provinces';
  static const typesEndPoint = '/customer/types';
  static const shopEndPoint = '/info';

  /// JWT login path (POST with query: username, password). Same as main app.
  static const String loginPath = 'jwt-auth/v1/token';

  /// POST { id_token } - exchange Firebase ID token for backend tokens.
  static const String firebaseExchangePath = 'recycleorigin/v1/auth/firebase';

  /// POST { refresh_token } - rotate refresh + access tokens.
  static const String refreshTokenPath = 'recycleorigin/v1/auth/refresh';

  /// POST { refresh_token, all? } - revoke session.
  static const String logoutPath = 'recycleorigin/v1/auth/logout';

  /// GET - currently authenticated user (requires JWT).
  static const String mePath = 'recycleorigin/v1/auth/me';
}

/// Strips [baseUrl] from an absolute request URL so Dio does not prefix
/// `baseUrl` a second time (`http://host/http://host/...`).
String stripApiBasePrefix(String path, String baseUrl) {
  var current = path.trim();
  for (var i = 0; i < 3; i++) {
    final next = _stripApiBasePrefixOnce(current, baseUrl);
    if (next == current) {
      return next;
    }
    current = next;
  }
  return current;
}

String _stripApiBasePrefixOnce(String path, String baseUrl) {
  if (path.isEmpty) {
    return path;
  }
  if (!path.startsWith('http://') && !path.startsWith('https://')) {
    return path.startsWith('/') ? path.substring(1) : path;
  }
  final request = Uri.tryParse(path);
  final base = Uri.tryParse(baseUrl);
  if (request == null ||
      base == null ||
      !request.hasScheme ||
      !base.hasScheme) {
    return path;
  }
  if (request.scheme != base.scheme ||
      request.host != base.host ||
      request.port != base.port) {
    return path;
  }
  var relative = request.path;
  if (relative.startsWith('/')) {
    relative = relative.substring(1);
  }
  if (request.hasQuery) {
    return '$relative?${request.query}';
  }
  return relative;
}
