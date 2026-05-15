import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

import '../support/fake_auth_bloc.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('shows validation when fields are empty', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider(
            create: (_) => FakeAuthBloc(),
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.textContaining('email'), findsWidgets);
      expect(find.textContaining('password'), findsWidgets);
    });

    testWidgets('successful login navigates to home route', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Stable bloc instance: avoid BlocProvider(create) inside [routes], which
      // can be rebuilt during login loading state and drop the in-flight login.
      final auth = FakeAuthBloc(loginResult: true);
      addTearDown(auth.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (_) => BlocProvider<AuthBloc>.value(
                  value: auth,
                  child: const LoginScreen(),
                ),
            NavigationBottomScreen.routeName: (_) =>
                const Scaffold(body: Text('signed_in_home')),
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('signed_in_home'), findsOneWidget);
    });

    testWidgets('failed login shows error dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider(
            create: (_) => FakeAuthBloc(loginResult: false),
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('network error shows connection dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider(
            create: (_) => FakeAuthBloc(loginThrows: true),
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('password visibility toggle changes obscureText', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider(
            create: (_) => FakeAuthBloc(),
            child: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final passwordFormField = find.byType(TextFormField).at(1);
      EditableText passwordEditable() => tester.widget<EditableText>(
            find.descendant(
              of: passwordFormField,
              matching: find.byType(EditableText),
            ),
          );
      expect(passwordEditable().obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(passwordEditable().obscureText, isFalse);
    });
  });
}
