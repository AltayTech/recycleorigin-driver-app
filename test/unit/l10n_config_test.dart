import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations configuration', () {
    test('supportedLocales includes ar, en, tr', () {
      final codes = AppLocalizations.supportedLocales
          .map((locale) => locale.languageCode)
          .toSet();
      expect(codes, containsAll(<String>['ar', 'en', 'tr']));
    });

    test('localizationsDelegates is non-empty', () {
      expect(AppLocalizations.localizationsDelegates, isNotEmpty);
    });
  });
}
