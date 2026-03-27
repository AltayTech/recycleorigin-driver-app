/// API URL constants. Same auth contract as main Recycle Origin app (JWT).
class Urls {
  /// Base URL for the backend (no trailing path).
  /// Local: Android emulator uses 10.0.2.2 to reach host; physical device use your PC IP (e.g. http://192.168.1.100:8080/).
  /// Production: use https://recycleorigin.com/
  static const String apiBaseUrl = 'http://10.0.2.2:8080/';

  /// REST API root (pasmands v1).
  static String get rootUrl => apiBaseUrl + 'rest/pasmands/v1';

  static const pasmandsEndPoint = '/pasmands';
  static const addressEndPoint = '/customer/address';
  static const regionEndPoint = '/customer/regions';
  static const collectsEndPoint = '/collects';

  /// Collects assigned to the logged-in driver (use this in driver app for "my requests").
  static const driverCollectsEndPoint = '/driver/collects';
  static const checkCompletedEndPoint = '/customer/completed';
  static const driverEndPoint = '/driver';
  static const deliveriesEndPoint = '/deliveries';
  static const clearingEndPoint = '/clearings';
  static const transactionsEndPoint = '/transactions';
  static const provincesEndPoint = '/provinces';
  static const typesEndPoint = '/customer/types';
  static const shopEndPoint = '/info';

  /// JWT login path (POST with query: username, password). Same as main app.
  static const String loginPath = 'jwt-auth/v1/token';
}
