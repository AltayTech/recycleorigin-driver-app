import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      assert(() {
        debugPrint('Firebase init skipped: $e\n$st');
        return true;
      }());
    }
  }
}
