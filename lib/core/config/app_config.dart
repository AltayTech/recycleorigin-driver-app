import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
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
    final fromEnv = _env('API_BASE_URL');
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv.endsWith('/') ? fromEnv : '$fromEnv/';
    }
    // Android emulator → host machine; Windows/iOS simulator → localhost.
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/';
    }
    return 'http://127.0.0.1:8080/';
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
