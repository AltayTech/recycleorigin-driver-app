import 'package:flutter/material.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: routes ?? const <String, WidgetBuilder>{},
      home: home,
    ),
  );
}
