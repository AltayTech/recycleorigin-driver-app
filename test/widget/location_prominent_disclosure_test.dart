import 'package:material_ui/material_ui.dart';
import 'package:recycleorigindriver/core/l10n/app_localizations_delegates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/location_prominent_disclosure.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showDriverLocationDisclosure(context),
                child: const Text('show'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('disclosure includes required Play phrases', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('Location sharing'), findsOneWidget);
    expect(find.textContaining('precise location'), findsOneWidget);
    expect(find.textContaining('when the app is not in use'), findsOneWidget);
    expect(find.textContaining('not used for ads'), findsOneWidget);
  });

  testWidgets('Continue pops true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDriverLocationDisclosure(context);
                },
                child: const Text('show'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Not now pops false', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDriverLocationDisclosure(context);
                },
                child: const Text('show'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
