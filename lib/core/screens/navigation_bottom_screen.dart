import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/auth_snackbars.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_list_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/store_collect_list_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/widgets/profile_view.dart';
import 'package:recycleorigindriver/features/home_feature/presentation/widgets/driver_session_header_banner.dart';
import 'package:recycleorigindriver/features/wallet_feature/presentation/wallet_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Tab order: collection (default), warehouse, wallet, profile.
enum _DriverShellTab {
  collection,
  warehouse,
  wallet,
  profile,
}

/// Driver shell: one primary [NavigationBar] (Material 3), [IndexedStack] to
/// preserve tab state, and a single app bar + drawer.
class NavigationBottomScreen extends StatefulWidget {
  static const routeName = '/NBS';

  const NavigationBottomScreen({super.key});

  @override
  State<NavigationBottomScreen> createState() => _NavigationBottomScreenState();
}

class _NavigationBottomScreenState extends State<NavigationBottomScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Collection is the default landing tab.
  int _selectedIndex = _DriverShellTab.collection.index;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AuthBloc>().getToken();
    });
  }

  void _onAuthSnackFlags(BuildContext context, AuthState state) {
    if (state.isFirstLogin) {
      showDriverLoginSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogin = false;
    }
    if (state.isFirstLogout) {
      showDriverLogoutSuccessSnackBar(context, context.l10n);
      context.read<AuthBloc>().isFirstLogout = false;
    }
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.exitDialogTitle,
          textAlign: TextAlign.center,
        ),
        content: Text(l10n.exitDialogMessage),
        actionsPadding: const EdgeInsets.all(10),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.noLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.yesLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _appBarTitle(AppLocalizations l10n) {
    final tab = _DriverShellTab.values[_selectedIndex];
    switch (tab) {
      case _DriverShellTab.collection:
        return l10n.collectionLabel;
      case _DriverShellTab.warehouse:
        return l10n.warehouseDeliveryLabel;
      case _DriverShellTab.wallet:
        return l10n.walletLabel;
      case _DriverShellTab.profile:
        return l10n.profileTabLabel;
    }
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final appBarTitle = _appBarTitle(l10n);
    final narrowNav = MediaQuery.sizeOf(context).width < 360;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.isFirstLogin != current.isFirstLogin ||
          previous.isFirstLogout != current.isFirstLogout,
      listener: _onAuthSnackFlags,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          final allow = await _confirmExit(context);
          if (allow && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            surfaceTintColor: Colors.transparent,
            iconTheme: IconThemeData(color: AppTheme.bg),
            leading: DrawerOrBackLeading(
              scaffoldKey: _scaffoldKey,
              iconColor: AppTheme.bg,
            ),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                appBarTitle,
                key: ValueKey<String>(appBarTitle),
                style: textTheme.titleLarge?.copyWith(
                  color: AppTheme.bg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          drawer: mainDrawerIfRootRoute(context),
          body: IndexedStack(
            index: _selectedIndex,
            children: const <Widget>[
              _CollectionTab(),
              _WarehouseTab(),
              _WalletTab(),
              _ProfileTab(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: EdgeInsets.fromLTRB(14, 0, 14, bottomInset > 0 ? 8 : 14),
            child: Material(
              color: AppTheme.white,
              elevation: 8,
              shadowColor: AppTheme.primary.withValues(alpha: 0.12),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 72,
                  backgroundColor: Colors.transparent,
                  indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (Set<WidgetState> states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.h1.withValues(alpha: 0.55),
                        letterSpacing: 0.1,
                      );
                    },
                  ),
                  iconTheme: WidgetStateProperty.resolveWith(
                    (Set<WidgetState> states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        color: selected ? AppTheme.primary : AppTheme.grey,
                        size: selected ? 26 : 24,
                      );
                    },
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelBehavior: narrowNav
                      ? NavigationDestinationLabelBehavior.onlyShowSelected
                      : NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: <Widget>[
                    NavigationDestination(
                      icon: const Icon(Icons.local_shipping_outlined),
                      selectedIcon: const Icon(Icons.local_shipping_rounded),
                      label: l10n.collectionLabel,
                      tooltip: l10n.collectionLabel,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.store_outlined),
                      selectedIcon: const Icon(Icons.store_rounded),
                      label: l10n.warehouseDeliveryLabel,
                      tooltip: l10n.warehouseDeliveryLabel,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon:
                          const Icon(Icons.account_balance_wallet_rounded),
                      label: l10n.walletLabel,
                      tooltip: l10n.walletLabel,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline_rounded),
                      selectedIcon: const Icon(Icons.person_rounded),
                      label: l10n.profileTabLabel,
                      tooltip: l10n.profileTabLabel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DriverSessionHeaderBanner(),
        Expanded(
          child: StoreCollectListScreen(embedInShell: true),
        ),
      ],
    );
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DriverSessionHeaderBanner(),
        Expanded(
          child: CollectListScreen(),
        ),
      ],
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    return const WalletScreen(embedInShell: true);
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ProfileView();
  }
}
