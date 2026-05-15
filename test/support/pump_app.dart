import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Wraps [home] in a [MaterialApp] with driver app localizations.
Future<void> pumpLocalizedApp(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
  Map<String, WidgetBuilder>? routes,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: routes,
      home: home,
    ),
  );
}
