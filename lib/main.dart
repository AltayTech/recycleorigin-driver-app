import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/app_bootstrap.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/app_theme_controller.dart';
import 'package:recycleorigindriver/core/navigation/app_navigator.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/auth_gate_screen.dart';
import 'package:recycleorigindriver/core/theme/driver_app_theme.dart';
import 'package:recycleorigindriver/features/about_feature/presentation/about_us_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/email_verification_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/forgot_password_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/register_screen.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/screens/clear_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_list_screen.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_create_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_ticket_detail_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/edit_personal_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/personal_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/vehicle_info_screen.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/screens/delivery_detail_screen.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/screens/send_delivery_screen.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_screen.dart';
import 'package:recycleorigindriver/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigindriver/features/map_feature/presentation/map_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_today_screen.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/screens/performance_screen.dart';
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
  const fromDefine = String.fromEnvironment('FLUTTER_ENV');
  // Debug/profile runs from IDE or `flutter run` use dev unless overridden.
  // Release builds default to prod (use `-t lib/main_prod.dart` for store).
  final environment =
      fromDefine.isNotEmpty ? fromDefine : (kDebugMode ? 'dev' : 'prod');
  await bootstrapDriverApp(_envFileFor(environment));
}

String _envFileFor(String environment) {
  switch (environment.trim().toLowerCase()) {
    case 'dev':
    case 'development':
      return 'assets/env/.env.dev';
    case 'staging':
      return 'assets/env/.env.staging';
    case 'prod':
    case 'production':
      return 'assets/env/.env.prod';
    default:
      return 'assets/env/.env.prod';
  }
}

/// Root widget for the driver application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) {
            final bloc = AuthBloc();
            ApiProvider.init(onUnauthorized: bloc.invalidateSession);
            return bloc;
          },
        ),
        BlocProvider<CustomerInfoBloc>(create: (_) => CustomerInfoBloc()),
        BlocProvider<WastesBloc>(create: (_) => WastesBloc()),
        BlocProvider<DeliveriesBloc>(create: (_) => DeliveriesBloc()),
        BlocProvider<ClearingsBloc>(create: (_) => ClearingsBloc()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.isLoggedIn && !curr.isLoggedIn,
        listener: (context, state) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (route) => false,
          );
        },
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeController.instance.themeModeNotifier,
          builder: (context, themeMode, _) {
            return ValueListenableBuilder<Locale>(
              valueListenable: AppLocaleController.instance.localeNotifier,
              builder: (context, locale, _) {
                return MaterialApp(
                  navigatorKey: appNavigatorKey,
                  debugShowCheckedModeBanner: false,
                  theme: DriverAppTheme.light(),
                  darkTheme: DriverAppTheme.dark(),
                  themeMode: themeMode,

                  onGenerateTitle: (context) => context.l10n.appTitle,
                  // Arabic uses RTL; English and Turkish stay LTR. App locale (not
                  // only the device locale) controls direction.
                  builder: (context, child) => Directionality(
                    textDirection: locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child ?? const SizedBox.shrink(),
                  ),

                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const AuthGateScreen(),
                  routes: {
                    NavigationBottomScreen.routeName: (ctx) =>
                        const NavigationBottomScreen(),
                    HomeScreen.routeName: (ctx) => const HomeScreen(),
                    LoginScreen.routeName: (ctx) => LoginScreen(),
                    RegisterScreen.routeName: (ctx) => const RegisterScreen(),
                    ForgotPasswordScreen.routeName: (ctx) =>
                        const ForgotPasswordScreen(),
                    EmailVerificationScreen.routeName: (ctx) =>
                        const EmailVerificationScreen(),
                    AboutUsScreen.routeName: (ctx) => AboutUsScreen(),
                    ContactWithUs.routeName: (ctx) => ContactWithUs(),
                    DriverSupportTicketsListScreen.routeName: (ctx) =>
                        const DriverSupportTicketsListScreen(),
                    DriverSupportTicketCreateScreen.routeName: (ctx) =>
                        const DriverSupportTicketCreateScreen(),
                    DriverSupportTicketDetailScreen.routeName: (ctx) =>
                        const DriverSupportTicketDetailScreen(),
                    DriverNotificationScreen.routeName: (ctx) =>
                        const DriverNotificationScreen(),
                    SettingsScreen.routeName: (ctx) => const SettingsScreen(),
                    PersonalInfoScreen.routeName: (ctx) =>
                        const PersonalInfoScreen(),
                    EditPersonalInfoScreen.routeName: (ctx) =>
                        const EditPersonalInfoScreen(),
                    VehicleInfoScreen.routeName: (ctx) =>
                        const VehicleInfoScreen(),
                    GuideScreen.routeName: (ctx) => const GuideScreen(),
                    MapScreen.routeName: (ctx) => MapScreen(),
                    CollectListScreen.routeName: (ctx) => CollectListScreen(),
                    WalletScreen.routeName: (ctx) => const WalletScreen(),
                    CollectDetailScreen.routeName: (ctx) =>
                        CollectDetailScreen(),
                    ClearScreen.routeName: (ctx) => ClearScreen(),
                    StatisticsScreen.routeName: (ctx) =>
                        const StatisticsScreen(),
                    PerformanceScreen.routeName: (ctx) =>
                        const PerformanceScreen(),
                    RouteTodayScreen.routeName: (ctx) =>
                        const RouteTodayScreen(),
                    SendDeliveryScreen.routeName: (ctx) => SendDeliveryScreen(),
                    DeliveryDetailScreen.routeName: (ctx) =>
                        DeliveryDetailScreen(),
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
