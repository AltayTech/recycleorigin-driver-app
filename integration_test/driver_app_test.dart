import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end smoke: real platform bindings, splash, auth gate → login.
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

    testWidgets('cold start reaches login after splash', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
