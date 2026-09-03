import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/app_theme_controller.dart';
import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/notifications/fcm_background.dart';
import 'package:recycleorigindriver/core/notifications/firebase_bootstrap.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/main.dart';

/// Boots the driver app with guarded initialization and Crashlytics.
Future<void> bootstrapDriverApp(String envFile) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _configureErrorHandlers();

      await _safeStep(
        'AppConfig',
        () => AppConfig.initialize(envFile: envFile),
      );
      await _safeStep(
        'AppLocaleController',
        () => AppLocaleController.instance.load(),
      );
      await _safeStep(
        'AppThemeController',
        () => AppThemeController.instance.load(),
      );
      await _safeStep(
        'AppInfoService',
        () => AppInfoService.instance.initialize(),
      );
      await _safeStep(
        'FirebaseBootstrap',
        () => FirebaseBootstrap.initialize(),
      );
      await _enableCrashlytics();

      if (FirebaseBootstrap.isInitialized) {
        await _safeStep('FCM background handler', () async {
          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );
        });
      }

      runApp(const MyApp());
    },
    (error, stack) {
      _recordFatal(error, stack);
      runApp(BootstrapErrorApp(error: error));
    },
  );
}

Future<void> _safeStep(String name, Future<void> Function() action) async {
  try {
    await action();
  } catch (error, stackTrace) {
    developer.log(
      'Bootstrap step failed: $name',
      name: 'recycleorigindriver.bootstrap',
      error: error,
      stackTrace: stackTrace,
    );
    await _recordNonFatal(error, stackTrace, reason: 'bootstrap:$name');
  }
}

Future<void> _enableCrashlytics() async {
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    _configureErrorHandlers(recordToCrashlytics: true);
  } catch (error, stackTrace) {
    developer.log(
      'Crashlytics init failed',
      name: 'recycleorigindriver.crashlytics',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

void _configureErrorHandlers({bool recordToCrashlytics = false}) {
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      'Flutter framework error',
      name: 'recycleorigindriver.flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (recordToCrashlytics) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    developer.log(
      'Platform dispatcher error',
      name: 'recycleorigindriver.platform',
      error: error,
      stackTrace: stack,
    );
    if (recordToCrashlytics) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            kDebugMode
                ? details.exception.toString()
                : 'Something went wrong loading this screen.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
}

Future<void> _recordFatal(Object error, StackTrace stack) async {
  developer.log(
    'Uncaught bootstrap error',
    name: 'recycleorigindriver.bootstrap',
    error: error,
    stackTrace: stack,
  );
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  } catch (_) {}
}

Future<void> _recordNonFatal(
  Object error,
  StackTrace stack, {
  required String reason,
}) async {
  if (kIsWeb || !FirebaseBootstrap.isInitialized) {
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
    );
  } catch (_) {}
}

/// Shown when bootstrap fails before the main app can start.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'RecycleOrigin Driver could not start',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  kDebugMode
                      ? error.toString()
                      : 'Please update the app or try again later.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
