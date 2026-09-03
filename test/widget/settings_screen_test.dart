import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/screens/settings_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

import '../support/fake_auth_bloc.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('shows settings title and language section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(create: (_) => FakeAuthBloc()),
              BlocProvider<CustomerInfoBloc>(create: (_) => CustomerInfoBloc()),
            ],
            child: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Language'), findsOneWidget);
    });
  });
}
