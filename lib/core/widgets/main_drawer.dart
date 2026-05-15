import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/features/about_feature/presentation/about_us_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_screen.dart';
import 'package:recycleorigindriver/features/statistics_feature/presentation/screens/statistics_screen.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/core/screens/settings_screen.dart';

/// Material 3 navigation drawer aligned with the customer app pattern.
class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  static const double _horizontalPadding = 14;
  static const double _tileRadius = 16;
  static const Color _heroGradientEnd = Color(0xFF1F8B61);

  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final appInfo = AppInfoService.instance;
      if (!appInfo.isInitialized) {
        await appInfo.initialize();
      }
      if (mounted) {
        setState(() {
          _appVersion = appInfo.shortVersion;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appVersion = 'v1.0.0';
        });
      }
    }
  }

  Widget _buildUserHeader({
    required bool isAuthenticated,
    required Driver? driver,
  }) {
    final l10n = context.l10n;

    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppTheme.primary, _heroGradientEnd],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.loginToAccountLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 12,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  icon: Icons.settings_rounded,
                  label: l10n.settingsTitle,
                  onTap: () => _navigateToRoute(SettingsScreen.routeName),
                ),
                _QuickActionChip(
                  icon: Icons.login_rounded,
                  label: l10n.loginLabel,
                  onTap: () => _navigateToRoute(LoginScreen.routeName),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final d = driver ?? Driver.fromJson(null);
    final data = d.driver_data;
    final fname = data.fname.trim();
    final lname = data.lname.trim();
    final email = data.email.trim();
    final mobile = data.mobile.trim();

    final displayName = fname.isNotEmpty || lname.isNotEmpty
        ? '$fname $lname'.trim()
        : email.isNotEmpty
            ? email
            : mobile.isNotEmpty
                ? mobile
                : l10n.userProfileLabel;

    final subtitle = email.isNotEmpty
        ? email
        : mobile.isNotEmpty
            ? mobile
            : l10n.settingsScreenIntro;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppTheme.primary, _heroGradientEnd],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: fname.isNotEmpty || lname.isNotEmpty
                    ? Center(
                        child: Text(
                          _nameInitials(displayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                icon: Icons.settings_rounded,
                label: l10n.settingsTitle,
                onTap: () => _navigateToRoute(SettingsScreen.routeName),
              ),
              _QuickActionChip(
                icon: Icons.person_rounded,
                label: l10n.userProfileLabel,
                onTap: () => _navigateToRoute(CustomerUserInfoScreen.routeName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nameInitials(String name) {
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final initials = tokens.take(2).map((t) => t[0]).join().toUpperCase();
    return initials.isEmpty ? 'D' : initials;
  }

  Widget _buildSectionTitle(String text) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: textStyle?.copyWith(
          color: Colors.white.withValues(alpha: 0.84),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDestinationTile({
    required _DrawerDestination destination,
    required bool selected,
    required bool destructive,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selectedColor = colors.surface.withValues(alpha: 0.92);
    final defaultFg = Colors.white.withValues(alpha: 0.94);
    final destructiveFg = colors.error;
    final foreground = destructive ? destructiveFg : defaultFg;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: 2,
      ),
      child: Material(
        color: selected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(_tileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_tileRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  destination.icon,
                  size: 22,
                  color: selected
                      ? colors.primary
                      : (destructive ? destructiveFg : foreground),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? colors.primary
                          : (destructive ? destructiveFg : foreground),
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToRoute(String routeName, {Object? arguments}) async {
    try {
      Navigator.of(context).pop();
      if (arguments != null) {
        await Navigator.of(context).pushNamed(routeName, arguments: arguments);
      } else {
        await Navigator.of(context).pushNamed(routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.navigationErrorPrefix}${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final parentContext = context;
    final l10n = parentContext.l10n;

    final bool? shouldNavigate = await showDialog<bool>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        var busy = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setD) {
            Future<void> onConfirm() async {
              setD(() => busy = true);
              try {
                parentContext.read<CustomerInfoBloc>().driver = parentContext
                    .read<CustomerInfoBloc>()
                    .driverZero;
                await parentContext.read<AuthBloc>().removeToken();
                parentContext.read<AuthBloc>().isFirstLogout = true;
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(true);
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${parentContext.l10n.signOutErrorPrefix}$e',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(false);
                }
              } finally {
                if (ctx.mounted) {
                  setD(() => busy = false);
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.logoutLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Text(
                l10n.logoutConfirmMessage,
                style: const TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancelLabel),
                ),
                TextButton(
                  onPressed: busy ? null : onConfirm,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: busy
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        )
                      : Text(
                          l10n.confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldNavigate == true && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(
        NavigationBottomScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name ?? '';
    final l10n = context.l10n;

    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppTheme.primary,
              AppTheme.primary.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final driver = context.watch<CustomerInfoBloc>().state.driver;
                  return _buildUserHeader(
                    isAuthenticated: authState.isAuth,
                    driver: authState.isAuth ? driver : null,
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionTitle(l10n.homeTabLabel),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.home_rounded,
                        title: l10n.homeTabLabel,
                        routeName: NavigationBottomScreen.routeName,
                      ),
                      selected:
                          currentRouteName == NavigationBottomScreen.routeName,
                      destructive: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          NavigationBottomScreen.routeName,
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.settings_rounded,
                        title: l10n.settingsTitle,
                        routeName: SettingsScreen.routeName,
                      ),
                      selected: currentRouteName == SettingsScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(SettingsScreen.routeName),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.bar_chart_rounded,
                        title: l10n.statisticsLabel,
                        routeName: StatisticsScreen.routeName,
                      ),
                      selected: currentRouteName == StatisticsScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(StatisticsScreen.routeName),
                    ),
                    _buildSectionTitle(l10n.guideLabel),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.menu_book_rounded,
                        title: l10n.guideLabel,
                        routeName: GuideScreen.routeName,
                      ),
                      selected: currentRouteName == GuideScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(GuideScreen.routeName),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.contact_mail_rounded,
                        title: l10n.contactUsLabel,
                        routeName: ContactWithUs.routeName,
                      ),
                      selected: currentRouteName == ContactWithUs.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(ContactWithUs.routeName),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.support_agent_rounded,
                        title: l10n.supportTicketsLabel,
                        routeName: DriverSupportTicketsListScreen.routeName,
                      ),
                      selected: currentRouteName ==
                          DriverSupportTicketsListScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(
                        DriverSupportTicketsListScreen.routeName,
                      ),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        routeName: DriverNotificationScreen.routeName,
                      ),
                      selected: currentRouteName ==
                          DriverNotificationScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(
                        DriverNotificationScreen.routeName,
                      ),
                    ),
                    _buildDestinationTile(
                      destination: _DrawerDestination(
                        icon: Icons.info_outline_rounded,
                        title: l10n.aboutUsLabel,
                        routeName: AboutUsScreen.routeName,
                      ),
                      selected: currentRouteName == AboutUsScreen.routeName,
                      destructive: false,
                      onTap: () => _navigateToRoute(AboutUsScreen.routeName),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              authState.isAuth
                                  ? l10n.userProfileLabel
                                  : l10n.loginLabel,
                            ),
                            _buildDestinationTile(
                              destination: _DrawerDestination(
                                icon: authState.isAuth
                                    ? Icons.person_rounded
                                    : Icons.login_rounded,
                                title: authState.isAuth
                                    ? l10n.userProfileLabel
                                    : l10n.loginLabel,
                                routeName: authState.isAuth
                                    ? CustomerUserInfoScreen.routeName
                                    : LoginScreen.routeName,
                              ),
                              selected: currentRouteName ==
                                  (authState.isAuth
                                      ? CustomerUserInfoScreen.routeName
                                      : LoginScreen.routeName),
                              destructive: false,
                              onTap: () => _navigateToRoute(
                                authState.isAuth
                                    ? CustomerUserInfoScreen.routeName
                                    : LoginScreen.routeName,
                              ),
                            ),
                            if (authState.isAuth)
                              _buildDestinationTile(
                                destination: _DrawerDestination(
                                  icon: Icons.logout_rounded,
                                  title: l10n.logoutLabel,
                                  routeName: '',
                                ),
                                selected: false,
                                destructive: true,
                                onTap: _handleLogout,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.66),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _appVersion,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerDestination {
  const _DrawerDestination({
    required this.icon,
    required this.title,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String routeName;
}
