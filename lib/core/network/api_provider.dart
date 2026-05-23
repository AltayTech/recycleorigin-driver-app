import 'package:recycleorigindriver/core/navigation/app_navigator.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';

/// Shared [ApiClient] for the driver app (JWT from secure storage).
class ApiProvider {
  ApiProvider._();

  static ApiClient? _client;

  static ApiClient get client {
    _client ??= ApiClient(
      onUnauthorized: () {
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
      },
    );
    return _client!;
  }

  static void reset() {
    _client = null;
  }
}
