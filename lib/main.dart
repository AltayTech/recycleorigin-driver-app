import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/auth_gate_screen.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/features/about_feature/presentation/about_us_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/screens/clear_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_list_screen.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_create_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_detail_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/screens/delivery_detail_screen.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/screens/send_delivery_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_screen.dart';
import 'package:recycleorigindriver/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigindriver/features/map_feature/presentation/map_screen.dart';
import 'package:recycleorigindriver/features/statistics_feature/presentation/screens/statistics_screen.dart';
import 'package:recycleorigindriver/features/wallet_feature/presentation/wallet_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'core/screens/settings_screen.dart';

/// Entry point for the driver app.
///
/// The app wires domain providers at the root and exposes a single Material
/// theme used by all collection, delivery, and profile flows.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocaleController.instance.load();
  await AppInfoService.instance.initialize();
  runApp(const MyApp());
}

/// Root widget for the driver application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light();
    final baseTextTheme = baseTheme.textTheme;

    final textTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: const Color.fromRGBO(20, 51, 51, 1),
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: const Color.fromRGBO(20, 51, 51, 1),
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTheme.primary,
      brightness: Brightness.light,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<CustomerInfoBloc>(create: (_) => CustomerInfoBloc()),
        BlocProvider<WastesBloc>(create: (_) => WastesBloc()),
        BlocProvider<DeliveriesBloc>(create: (_) => DeliveriesBloc()),
        BlocProvider<ClearingsBloc>(create: (_) => ClearingsBloc()),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.instance.localeNotifier,
        builder: (context, locale, _) {
          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.appTitle,
            // Arabic uses RTL; English and Turkish stay LTR. App locale (not
            // only the device locale) controls direction.
            builder: (context, child) => Directionality(
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            ),
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
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthGateScreen(),
            routes: {
              NavigationBottomScreen.routeName: (ctx) =>
                  NavigationBottomScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              AboutUsScreen.routeName: (ctx) => AboutUsScreen(),
              ContactWithUs.routeName: (ctx) => ContactWithUs(),
              DriverSupportTicketsListScreen.routeName: (ctx) =>
                  const DriverSupportTicketsListScreen(),
              DriverSupportTicketCreateScreen.routeName: (ctx) =>
                  const DriverSupportTicketCreateScreen(),
              DriverSupportTicketDetailScreen.routeName: (ctx) =>
                  const DriverSupportTicketDetailScreen(),
              SettingsScreen.routeName: (ctx) => const SettingsScreen(),
              CustomerDetailInfoEditScreen.routeName: (ctx) =>
                  CustomerDetailInfoEditScreen(),
              CustomerUserInfoScreen.routeName: (ctx) =>
                  CustomerUserInfoScreen(),
              GuideScreen.routeName: (ctx) => const GuideScreen(),
              MapScreen.routeName: (ctx) => MapScreen(),
              CollectListScreen.routeName: (ctx) => CollectListScreen(),
              WalletScreen.routeName: (ctx) => WalletScreen(),
              CollectDetailScreen.routeName: (ctx) => CollectDetailScreen(),
              ClearScreen.routeName: (ctx) => ClearScreen(),
              StatisticsScreen.routeName: (ctx) => StatisticsScreen(),
              SendDeliveryScreen.routeName: (ctx) => SendDeliveryScreen(),
              DeliveryDetailScreen.routeName: (ctx) => DeliveryDetailScreen(),
            },
          );
        },
      ),
    );
  }
}
