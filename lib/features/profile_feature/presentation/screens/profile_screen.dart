import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/screens/settings_screen.dart';
import 'package:recycleorigindriver/features/about_feature/presentation/about_us_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/edit_personal_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/personal_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/vehicle_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_app_version_footer.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_error_view.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_hero.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_logged_out_view.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_logout.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_section_card.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_skeleton.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_today_screen.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/screens/performance_screen.dart';
import 'package:recycleorigindriver/features/wallet_feature/presentation/wallet_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver profile tab: identity hero, quick stats, and account hub sections.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) => state.isAuth,
      builder: (context, isAuthenticated) {
        if (!isAuthenticated) {
          return const ProfileLoggedOutView();
        }
        return const _ProfileAuthenticatedContent();
      },
    );
  }
}

class _ProfileAuthenticatedContent extends StatefulWidget {
  const _ProfileAuthenticatedContent();

  @override
  State<_ProfileAuthenticatedContent> createState() =>
      _ProfileAuthenticatedContentState();
}

class _ProfileAuthenticatedContentState
    extends State<_ProfileAuthenticatedContent> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await context.read<CustomerInfoBloc>().getCustomer();
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ProfileSkeleton();
    }

    if (_hasError) {
      return ProfileErrorView(onRetry: _loadProfile);
    }

    return BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _loadProfile,
          child: _ProfileScrollContent(driver: state.driver),
        );
      },
    );
  }
}

class _ProfileScrollContent extends StatelessWidget {
  const _ProfileScrollContent({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: ProfileHero(
            driver: driver,
            onEditPressed: () {
              Navigator.of(context).pushNamed(EditPersonalInfoScreen.routeName);
            },
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              ProfileSection(
                title: l10n.accountSectionTitle,
                children: <Widget>[
                  ProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.personalInfoLabel,
                    onTap: () =>
                        _openRoute(context, PersonalInfoScreen.routeName),
                  ),
                  ProfileTile(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.myVehicleLabel,
                    trailing: _vehicleSummary(context, driver),
                    onTap: () =>
                        _openRoute(context, VehicleInfoScreen.routeName),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProfileSection(
                title: l10n.activitySectionTitle,
                children: <Widget>[
                  ProfileTile(
                    icon: Icons.bar_chart_rounded,
                    title: l10n.statisticsLabel,
                    onTap: () =>
                        _openRoute(context, PerformanceScreen.routeName),
                  ),
                  ProfileTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.walletLabel,
                    trailing: driver.money.trim().isNotEmpty
                        ? driver.money
                        : null,
                    onTap: () => _openRoute(context, WalletScreen.routeName),
                  ),
                  ProfileTile(
                    icon: Icons.route_rounded,
                    title: l10n.myRouteLabel,
                    onTap: () =>
                        _openRoute(context, RouteTodayScreen.routeName),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Locale>(
                valueListenable: AppLocaleController.instance.localeNotifier,
                builder: (context, locale, _) {
                  return ProfileSection(
                    title: l10n.inboxPreferencesSectionTitle,
                    children: <Widget>[
                      ProfileTile(
                        icon: Icons.notifications_outlined,
                        title: l10n.notificationsLabel,
                        onTap: () => _openRoute(
                          context,
                          DriverNotificationScreen.routeName,
                        ),
                      ),
                      ProfileTile(
                        icon: Icons.settings_outlined,
                        title: l10n.settingsTitle,
                        trailing: _currentLanguageLabel(l10n, locale),
                        onTap: () =>
                            _openRoute(context, SettingsScreen.routeName),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ProfileSection(
                title: l10n.supportSectionTitle,
                children: <Widget>[
                  ProfileTile(
                    icon: Icons.menu_book_outlined,
                    title: l10n.guideLabel,
                    onTap: () => _openRoute(context, GuideScreen.routeName),
                  ),
                  ProfileTile(
                    icon: Icons.support_agent_outlined,
                    title: l10n.supportTicketsLabel,
                    onTap: () => _openRoute(
                      context,
                      DriverSupportTicketsListScreen.routeName,
                    ),
                  ),
                  ProfileTile(
                    icon: Icons.contact_mail_outlined,
                    title: l10n.contactUsLabel,
                    onTap: () => _openRoute(context, ContactWithUs.routeName),
                  ),
                  ProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.aboutUsLabel,
                    onTap: () => _openRoute(context, AboutUsScreen.routeName),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const ProfileSignOutButton(),
              const SizedBox(height: 16),
              const ProfileAppVersionFooter(),
            ]),
          ),
        ),
      ],
    );
  }

  static void _openRoute(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  static String? _vehicleSummary(BuildContext context, Driver driver) {
    final l10n = context.l10n;
    final vehicle = driver.car.name.trim();
    final color = driver.car_color.name.trim();
    final plate = driver.car_number.trim();

    if (vehicle.isEmpty && color.isEmpty && plate.isEmpty) {
      return null;
    }

    return l10n.vehicleSummaryLabel(
      vehicle.isNotEmpty ? vehicle : '—',
      color.isNotEmpty ? color : '—',
      plate.isNotEmpty ? plate : '—',
    );
  }

  static String _currentLanguageLabel(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return l10n.turkishLabel;
      case 'ar':
        return l10n.arabicLabel;
      default:
        return l10n.englishLabel;
    }
  }
}
