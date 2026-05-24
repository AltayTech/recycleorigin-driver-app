import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/core/screens/settings_screen.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/ui/top_bar.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/core/widgets/star_rating_widget.dart';
import 'package:recycleorigindriver/features/about_feature/presentation/about_us_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_today_screen.dart';
import 'package:recycleorigindriver/features/statistics_feature/presentation/screens/statistics_screen.dart';
import 'package:recycleorigindriver/features/wallet_feature/presentation/wallet_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

const Color _heroGradientEnd = Color(0xFF1F8B61);

/// Driver profile tab: identity hero, quick stats, and account hub sections.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) => state.isAuth,
      builder: (context, isAuthenticated) {
        if (!isAuthenticated) {
          return const _LoggedOutView();
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
      return const _ProfileSkeleton();
    }

    if (_hasError) {
      return _ErrorView(onRetry: _loadProfile);
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
          child: _ProfileHero(driver: driver),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                _ProfileSection(
                  title: l10n.accountSectionTitle,
                  tiles: <Widget>[
                    _ProfileTile(
                      icon: Icons.person_outline_rounded,
                      title: l10n.personalInfoLabel,
                      onTap: () => _openRoute(
                        context,
                        CustomerUserInfoScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.edit_outlined,
                      title: l10n.editProfileLabel,
                      onTap: () => _openRoute(
                        context,
                        CustomerDetailInfoEditScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.local_shipping_outlined,
                      title: l10n.myVehicleLabel,
                      trailing: _vehicleSummary(context, driver),
                      onTap: () => _openRoute(
                        context,
                        CustomerUserInfoScreen.routeName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfileSection(
                  title: l10n.activitySectionTitle,
                  tiles: <Widget>[
                    _ProfileTile(
                      icon: Icons.bar_chart_rounded,
                      title: l10n.statisticsLabel,
                      onTap: () => _openRoute(
                        context,
                        StatisticsScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.walletLabel,
                      trailing: driver.money.trim().isNotEmpty
                          ? driver.money
                          : null,
                      onTap: () => _openRoute(
                        context,
                        WalletScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.route_rounded,
                      title: l10n.myRouteLabel,
                      onTap: () => _openRoute(
                        context,
                        RouteTodayScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: l10n.notificationsLabel,
                      onTap: () => _openRoute(
                        context,
                        DriverNotificationScreen.routeName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<Locale>(
                  valueListenable: AppLocaleController.instance.localeNotifier,
                  builder: (context, locale, _) {
                    return _ProfileSection(
                      title: l10n.preferencesSectionTitle,
                      tiles: <Widget>[
                        _ProfileTile(
                          icon: Icons.settings_outlined,
                          title: l10n.settingsTitle,
                          onTap: () => _openRoute(
                            context,
                            SettingsScreen.routeName,
                          ),
                        ),
                        _ProfileTile(
                          icon: Icons.translate_rounded,
                          title: l10n.languageTitle,
                          trailing: _currentLanguageLabel(l10n, locale),
                          onTap: () => _openRoute(
                            context,
                            SettingsScreen.routeName,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ProfileSection(
                  title: l10n.supportSectionTitle,
                  tiles: <Widget>[
                    _ProfileTile(
                      icon: Icons.menu_book_outlined,
                      title: l10n.guideLabel,
                      onTap: () => _openRoute(
                        context,
                        GuideScreen.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.contact_mail_outlined,
                      title: l10n.contactUsLabel,
                      onTap: () => _openRoute(
                        context,
                        ContactWithUs.routeName,
                      ),
                    ),
                    _ProfileTile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.aboutUsLabel,
                      onTap: () => _openRoute(
                        context,
                        AboutUsScreen.routeName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SignOutButton(),
                const SizedBox(height: 16),
                const _AppVersionFooter(),
              ],
            ),
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

  static String _currentLanguageLabel(
    AppLocalizations l10n,
    Locale locale,
  ) {
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final data = driver.driver_data;
    final displayName = _ProfileDisplayName.fromDriver(driver, l10n);
    final subtitle = data.email.trim().isNotEmpty
        ? data.email.trim()
        : data.mobile.trim().isNotEmpty
            ? data.mobile.trim()
            : data.phone.trim();

    return Column(
      children: <Widget>[
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colorScheme.primary,
                      _heroGradientEnd,
                    ],
                  ),
                ),
              ),
              const TopBar(height: 200),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: l10n.editProfileLabel,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      CustomerUserInfoScreen.routeName,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 52,
                child: Row(
                  children: <Widget>[
                    _ProfileAvatar(
                      imageUrl: _resolveDriverImageUrl(data.driver_image),
                      initials: _nameInitials(displayName),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Chip(
                                label: Text(
                                  l10n.driverRoleLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.22),
                                labelStyle: const TextStyle(color: Colors.white),
                                side: BorderSide.none,
                                padding: EdgeInsets.zero,
                              ),
                              if (driver.averageRating != null)
                                StarRatingDisplay(
                                  value: driver.averageRating!,
                                  size: 16,
                                  color: Colors.amber.shade300,
                                )
                              else
                                Text(
                                  l10n.noRatingLabel,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HeroStatsRow(driver: driver),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.initials,
  });

  final String? imageUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    const radius = 32.0;

    if (imageUrl == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: ClipOval(
        child: Image.network(
          imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroStatsRow extends StatelessWidget {
  const _HeroStatsRow({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ratingText = driver.averageRating != null
        ? driver.averageRating!.toStringAsFixed(1)
        : l10n.noRatingLabel;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _HeroStatChip(
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.walletBalanceLabel,
                value: driver.money.trim().isNotEmpty ? driver.money : '—',
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppTheme.secondary,
            ),
            Expanded(
              child: _HeroStatChip(
                icon: Icons.star_rounded,
                label: l10n.ratingLabel,
                value: ratingText,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: AppTheme.secondary,
            ),
            Expanded(
              child: _HeroStatChip(
                icon: Icons.store_outlined,
                label: l10n.storesCountLabel,
                value: '${driver.stores.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.h1,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.grey,
              ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.tiles,
  });

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
          ),
        ),
        Card(
          elevation: 2,
          shadowColor: Colors.black26,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.white,
          child: Column(
            children: _interleaveDividers(tiles),
          ),
        ),
      ],
    );
  }

  static List<Widget> _interleaveDividers(List<Widget> tiles) {
    if (tiles.isEmpty) {
      return tiles;
    }
    final result = <Widget>[tiles.first];
    for (var i = 1; i < tiles.length; i++) {
      result.add(
        const Divider(height: 1, indent: 56, color: AppTheme.secondary),
      );
      result.add(tiles[i]);
    }
    return result;
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.primary;
    const titleColor = AppTheme.h1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[
                Flexible(
                  child: Text(
                    trailing!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.grey.withValues(alpha: 0.8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.error,
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _ProfileLogout.handleLogout(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.logout_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              l10n.logoutLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared logout flow aligned with [MainDrawer].
class _ProfileLogout {
  static Future<void> handleLogout(BuildContext context) async {
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
                parentContext.read<CustomerInfoBloc>().driver =
                    parentContext.read<CustomerInfoBloc>().driverZero;
                await parentContext.read<AuthBloc>().removeToken();
                if (!parentContext.mounted) {
                  return;
                }
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
              content: Text(l10n.logoutConfirmMessage),
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

    if (shouldNavigate == true && parentContext.mounted) {
      Navigator.of(parentContext).pushNamedAndRemoveUntil(
        NavigationBottomScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }
}

class _AppVersionFooter extends StatefulWidget {
  const _AppVersionFooter();

  @override
  State<_AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<_AppVersionFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = AppInfoService.instance;
      if (!info.isInitialized) {
        await info.initialize();
      }
      if (mounted) {
        setState(() {
          _version = info.shortVersion;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _version = 'v1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = DateTime.now().year.toString();

    return Column(
      children: <Widget>[
        if (_version.isNotEmpty)
          Text(
            l10n.appVersionLabel(_version),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.grey,
                ),
          ),
        const SizedBox(height: 4),
        Text(
          l10n.profileCopyrightLabel(year, l10n.appTitle),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.grey.withValues(alpha: 0.85),
              ),
        ),
      ],
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: AppTheme.bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.account_circle_outlined,
                  size: 88,
                  color: colorScheme.primary.withValues(alpha: 0.55),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.notLoggedInLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.h1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginRequiredDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.grey,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(l10n.loginToAccountLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: AppTheme.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.profileLoadErrorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.h1,
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          const _SkeletonBox(height: 200, borderRadius: 0),
          Transform.translate(
            offset: const Offset(0, -28),
            child: const _SkeletonBox(height: 88, borderRadius: 16),
          ),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 18, width: 100),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 160, borderRadius: 12),
          const SizedBox(height: 16),
          const _SkeletonBox(height: 18, width: 100),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 200, borderRadius: 12),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width,
    this.borderRadius = 8,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _ProfileDisplayName {
  static String fromDriver(Driver driver, AppLocalizations l10n) {
    final fname = driver.driver_data.fname.trim();
    final lname = driver.driver_data.lname.trim();
    final email = driver.driver_data.email.trim();
    final mobile = driver.driver_data.mobile.trim();

    if (fname.isNotEmpty || lname.isNotEmpty) {
      return '$fname $lname'.trim();
    }
    if (email.isNotEmpty) {
      return email;
    }
    if (mobile.isNotEmpty) {
      return mobile;
    }
    return l10n.userProfileLabel;
  }
}

String? _resolveDriverImageUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = Urls.apiBaseUrl.endsWith('/')
      ? Urls.apiBaseUrl.substring(0, Urls.apiBaseUrl.length - 1)
      : Urls.apiBaseUrl;
  if (trimmed.startsWith('/')) {
    return '$base$trimmed';
  }
  return '$base/$trimmed';
}

String _nameInitials(String name) {
  final tokens =
      name.trim().split(RegExp(r'\s+')).where((String t) => t.isNotEmpty);
  final initials = tokens.take(2).map((String t) => t[0]).join().toUpperCase();
  return initials.isEmpty ? 'D' : initials;
}
