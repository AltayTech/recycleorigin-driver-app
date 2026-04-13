import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/ui/top_bar.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_list_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_user_info_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var _isLoading = false;
  bool _isInit = true;

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<CustomerInfoBloc>().getCustomer();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.connectionRetryMessage,
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadCustomer();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  static int _profileGridCrossAxisCount(double width) {
    if (width >= 900) {
      return 4;
    }
    if (width >= 600) {
      return 3;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().state.isAuth;
    final textScaler = MediaQuery.textScalerOf(context);

    if (!isLogin) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.l10n.notLoggedInLabel,
                  textAlign: TextAlign.center,
                  textScaler: textScaler,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  child: Text(context.l10n.loginToAccountLabel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: SpinKitFadingCircle(
          itemBuilder: _buildLoadingItem,
        ),
      );
    }

    return ColoredBox(
      color: AppTheme.bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final topBarHeight = (maxW * 0.42).clamp(120.0, 200.0);
          final crossCount = _profileGridCrossAxisCount(maxW);
          final horizontalPad = (maxW * 0.04).clamp(12.0, 24.0);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: topBarHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.hardEdge,
                    children: <Widget>[
                      TopBar(height: topBarHeight),
                      Positioned(
                        left: horizontalPad,
                        right: horizontalPad,
                        bottom: 16,
                        child: Text(
                          context.l10n.userProfileTitle,
                          textAlign: TextAlign.center,
                          textScaler: textScaler,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: const <Shadow>[
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  16,
                  horizontalPad,
                  24,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _ProfileMenuItem(
                        imagePath: 'assets/images/orders_list.png',
                        label: context.l10n.statisticsLabel,
                        onTap: () {
                          // TODO: Navigate to statistics screen for driver.
                        },
                      ),
                      _ProfileMenuItem(
                        imagePath: 'assets/images/user_Icon.png',
                        label: context.l10n.personalInfoLabel,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            CustomerUserInfoScreen.routeName,
                          );
                        },
                      ),
                      _ProfileMenuItem(
                        imagePath: 'assets/images/message_icon.png',
                        label: '',
                        onTap: () {
                          // TODO: Navigate to driver messages when implemented.
                        },
                      ),
                      _ProfileMenuItem(
                        imagePath: 'assets/images/main_page_request_ic.png',
                        label: context.l10n.requestTabLabel,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(CollectListScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildLoadingItem(BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index.isEven ? Colors.grey : Colors.grey.shade400,
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  final String imagePath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final pad = (MediaQuery.sizeOf(context).width * 0.02).clamp(6.0, 14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          textScaler: textScaler,
                          maxLines: 2,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
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
