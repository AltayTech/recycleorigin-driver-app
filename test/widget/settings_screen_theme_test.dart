import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/app_theme_controller.dart';
import 'package:recycleorigindriver/core/screens/settings_screen.dart';
import 'package:recycleorigindriver/core/theme/driver_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen appearance', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AppThemeController.instance.load();
    });

    testWidgets('renders theme mode options', (tester) async {
      await pumpLocalizedApp(
        tester,
        const SettingsScreen(),
        theme: DriverAppTheme.light(),
        darkTheme: DriverAppTheme.dark(),
        themeMode: ThemeMode.light,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('updates theme controller when dark is tapped', (tester) async {
      await pumpLocalizedApp(
        tester,
        const SettingsScreen(),
        theme: DriverAppTheme.light(),
        darkTheme: DriverAppTheme.dark(),
        themeMode: ThemeMode.light,
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Dark'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.dark,
      );
    });
  });
}
