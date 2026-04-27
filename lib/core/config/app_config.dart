import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  static String? _env(String key) {
    if (!_initialized) {
      return null;
    }
    return dotenv.env[key];
  }

  static String get apiBaseUrl {
    final url = _env('API_BASE_URL') ?? 'http://10.0.2.2:8080/';
    return url.endsWith('/') ? url : '$url/';
  }

  static String get environment {
    return _env('ENVIRONMENT') ?? 'development';
  }

  static Future<void> initialize({required String envFile}) async {
    try {
      await dotenv.load(fileName: envFile);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }
}
