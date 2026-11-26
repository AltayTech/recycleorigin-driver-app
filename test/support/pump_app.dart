import 'package:material_ui/material_ui.dart';
import 'package:recycleorigindriver/core/l10n/app_localizations_delegates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Wraps [home] in a [MaterialApp] with driver app localizations.
Future<void> pumpLocalizedApp(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
  Map<String, WidgetBuilder>? routes,
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: routes ?? const <String, WidgetBuilder>{},
      home: home,
    ),
  );
}
