import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recycleorigindriver/core/config/app_config_exception.dart';

class AppConfig {
  AppConfig._();

  static bool _initialized = false;
  static String _activeEnvFile = 'assets/env/.env.dev';

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
    if (isProduction) {
      throw AppConfigException(
        'Production build requires API_BASE_URL in $_activeEnvFile',
      );
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

  static bool get isProduction {
    return environment == 'production';
  }

  /// When false, the warehouse/delivery tab shows Coming Soon.
  static bool get enableWarehouseDeliveries {
    final raw = _env('ENABLE_WAREHOUSE_DELIVERIES');
    if (raw == null || raw.isEmpty) {
      return false;
    }
    switch (raw.toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'on':
        return true;
      default:
        return false;
    }
  }

  static Future<void> initialize({required String envFile}) async {
    _activeEnvFile = envFile;
    try {
      await dotenv.load(fileName: envFile);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
    _validateProductionConfig();
  }

  static void _validateProductionConfig() {
    if (!isProduction) {
      return;
    }
    if (!_initialized) {
      throw AppConfigException(
        'Production build requires $_activeEnvFile to load successfully',
      );
    }
    if (!apiBaseUrl.startsWith('https://')) {
      throw AppConfigException(
        'Production API_BASE_URL must use HTTPS (got $apiBaseUrl)',
      );
    }
  }
}
