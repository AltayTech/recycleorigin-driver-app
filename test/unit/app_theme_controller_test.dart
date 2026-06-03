import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/app_theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AppThemeController.instance.load();
    });

    test('loads system as default when nothing is persisted', () async {
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.system,
      );
    });

    test('persists and restores selected theme mode', () async {
      await AppThemeController.instance.setThemeMode(ThemeMode.dark);
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.dark,
      );

      await AppThemeController.instance.load();
      expect(
        AppThemeController.instance.themeModeNotifier.value,
        ThemeMode.dark,
      );
    });
  });
}
