import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/provider/clearings.dart';
import 'package:recycleorigindriver/screens/delivery_detail_screen.dart';
import 'package:recycleorigindriver/screens/statistics_screen.dart';

import './provider/app_theme.dart';
import './provider/auth.dart';
import './provider/wastes.dart';
import './screens/about_us_screen.dart';
import './screens/clear_screen.dart';
import './screens/collect_detail_screen.dart';
import './screens/contact_with_us_screen.dart';
import './screens/customer_info/customer_user_info_screen.dart';
import './screens/home_screen.dart';
import './screens/map_screen.dart';
import './screens/navigation_bottom_screen.dart';
import './screens/wallet_screen.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'provider/customer_info.dart';
import 'provider/deliveries.dart';
import 'screens/collect_list_screen.dart';
import 'screens/customer_info/customer_detail_info_edit_screen.dart';
import 'screens/customer_info/login_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/send_delivery_screen.dart';
import 'screens/splash_Screen.dart';

/// Entry point for the driver app.
///
/// The app wires domain providers at the root and exposes a single Material
/// theme used by all collection, delivery, and profile flows.
void main() => runApp(const MyApp());

/// Root widget for the driver application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light();
    final baseTextTheme = baseTheme.textTheme;

    final textTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: 'Iransans',
        color: const Color.fromRGBO(20, 51, 51, 1),
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: 'Iransans',
        color: const Color.fromRGBO(20, 51, 51, 1),
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontFamily: 'Iransans',
        fontWeight: FontWeight.bold,
      ),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTheme.primary,
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerInfo(),
        ),
        ChangeNotifierProvider(
          create: (context) => Wastes(),
        ),
        ChangeNotifierProvider(
          create: (context) => Deliveries(),
        ),
        ChangeNotifierProvider(
          create: (context) => Clearings(),
        ),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: AppTheme.bg,
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.appBarColor,
            foregroundColor: AppTheme.appBarIconColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: textTheme.titleLarge?.copyWith(
              color: AppTheme.bg,
            ),
          ),
          textTheme: textTheme,
          cardTheme: CardThemeData(
            color: AppTheme.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppTheme.bg,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.grey,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            titleTextStyle: textTheme.titleLarge?.copyWith(
              color: AppTheme.black,
            ),
            contentTextStyle: textTheme.bodyMedium?.copyWith(
              color: AppTheme.grey,
            ),
          ),
        ),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreens(),
        routes: {
          NavigationBottomScreen.routeName: (ctx) => NavigationBottomScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          AboutUsScreen.routeName: (ctx) => AboutUsScreen(),
          ContactWithUs.routeName: (ctx) => ContactWithUs(),
          CustomerDetailInfoEditScreen.routeName: (ctx) =>
              CustomerDetailInfoEditScreen(),
          CustomerUserInfoScreen.routeName: (ctx) => CustomerUserInfoScreen(),
          GuideScreen.routeName: (ctx) => GuideScreen(),
          MapScreen.routeName: (ctx) => MapScreen(),
          CollectListScreen.routeName: (ctx) => CollectListScreen(),
          WalletScreen.routeName: (ctx) => WalletScreen(),
          CollectDetailScreen.routeName: (ctx) => CollectDetailScreen(),
          ClearScreen.routeName: (ctx) => ClearScreen(),
          StatisticsScreen.routeName: (ctx) => StatisticsScreen(),
          SendDeliveryScreen.routeName: (ctx) => SendDeliveryScreen(),
          DeliveryDetailScreen.routeName: (ctx) => DeliveryDetailScreen(),
        },
      ),
    );
  }
}
