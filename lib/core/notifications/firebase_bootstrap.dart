import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase from native config files (Android/iOS).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  /// Whether [Firebase.initializeApp] completed successfully.
  static bool get isInitialized => _initialized;

  /// No-op on web. Logs failures in all modes so release is not silent.
  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e, st) {
      _initialized = false;
      developer.log(
        'Firebase init failed',
        name: 'recycleorigindriver.firebase',
        error: e,
        stackTrace: st,
      );
      assert(() {
        debugPrint('Firebase init skipped: $e');
        debugPrint('$st');
        return true;
      }());
    }
  }
}
