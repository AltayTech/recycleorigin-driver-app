import 'package:recycleorigindriver/core/config/app_config.dart';

/// API URL constants. Same auth contract as main Recycle Origin app (JWT).
class Urls {
  /// Base URL for the backend (no trailing path).
  /// Local: Android emulator uses 10.0.2.2 to reach host; physical device use your PC IP (e.g. http://192.168.1.100:8080/).
  /// Production: use https://recycleorigin.com/
  static String get apiBaseUrl => AppConfig.apiBaseUrl;

  /// REST API root (pasmands v1).
  static String get rootUrl => apiBaseUrl + 'pasmands/v1';

  static const pasmandsEndPoint = '/pasmands';
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
  static const deliveriesEndPoint = '/deliveries';
  static const clearingEndPoint = '/clearings';
  static const transactionsEndPoint = '/transactions';
  static const walletEndPoint = '/wallet';
  static const walletTransactionsEndPoint = '/wallet/transactions';
  static const walletWithdrawEndPoint = '/wallet/withdraw';
  static const provincesEndPoint = '/provinces';
  static const typesEndPoint = '/customer/types';
  static const shopEndPoint = '/info';

  /// JWT login path (POST with query: username, password). Same as main app.
  static const String loginPath = 'jwt-auth/v1/token';

  /// POST { id_token } - exchange Firebase ID token for backend tokens.
  static const String firebaseExchangePath = 'pasmands/v1/auth/firebase';

  /// POST { refresh_token } - rotate refresh + access tokens.
  static const String refreshTokenPath = 'pasmands/v1/auth/refresh';

  /// POST { refresh_token, all? } - revoke session.
  static const String logoutPath = 'pasmands/v1/auth/logout';

  /// GET - currently authenticated user (requires JWT).
  static const String mePath = 'pasmands/v1/auth/me';
}

