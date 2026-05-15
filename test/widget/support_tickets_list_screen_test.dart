import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

void main() {
  group('DriverSupportTicketsListScreen', () {
    testWidgets('builds without auth (no crash)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
              BlocProvider<CustomerInfoBloc>(create: (_) => CustomerInfoBloc()),
            ],
            child: const DriverSupportTicketsListScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Support tickets'), findsOneWidget);
    });
  });
}
