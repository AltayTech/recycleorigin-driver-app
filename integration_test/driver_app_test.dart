import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end smoke: real platform bindings, startup shell → login.
///
/// Run on a device or emulator:
/// `flutter test integration_test/driver_app_test.dart`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Driver app integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppLocaleController.instance.load();
      await AppInfoService.instance.initialize();
    });

    testWidgets('cold start reaches login after auth check', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);

      // Startup shows an indeterminate progress indicator, so pumpAndSettle
      // never completes; advance time until login is pushed.
      const step = Duration(milliseconds: 200);
      for (var i = 0; i < 100; i++) {
        await tester.pump(step);
        if (find.byType(LoginScreen).evaluate().isNotEmpty) break;
      }

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
