import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Root widget smoke test (Flutter default entry under `test/`).
void main() {
  group('MyApp smoke', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await AppLocaleController.instance.load();
      await AppInfoService.instance.initialize();
    });

    testWidgets('builds Material 3 app shell', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}
