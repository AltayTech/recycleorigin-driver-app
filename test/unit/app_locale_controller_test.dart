import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocaleController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppLocaleController.instance.load();
    });

    test('load uses English when no preference stored', () {
      expect(
        AppLocaleController.instance.localeNotifier.value.languageCode,
        'en',
      );
    });

    test('setLocaleCode persists Turkish', () async {
      await AppLocaleController.instance.setLocaleCode('tr');
      expect(
        AppLocaleController.instance.localeNotifier.value.languageCode,
        'tr',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), 'tr');
    });

    test('setLocaleCode resolves Arabic', () async {
      await AppLocaleController.instance.setLocaleCode('ar');
      expect(
        AppLocaleController.instance.localeNotifier.value.languageCode,
        'ar',
      );
    });
  });
}
