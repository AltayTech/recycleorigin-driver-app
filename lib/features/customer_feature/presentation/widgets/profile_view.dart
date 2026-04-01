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

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<AuthBloc>().state.isAuth;

    final mediaQuery = MediaQuery.of(context);
    final deviceSizeWidth = mediaQuery.size.width;
    final deviceSizeHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor;

    if (!isLogin) {
      return Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                context.l10n.notLoggedInLabel,
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  context.l10n.loginToAccountLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
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

    return SizedBox(
      width: deviceSizeWidth,
      height: deviceSizeHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: deviceSizeHeight * 0,
            width: deviceSizeWidth,
            child: TopBar(),
          ),
          Positioned(
            top: deviceSizeHeight * 0.070,
            width: deviceSizeWidth * 0.6,
            right: 20,
            child: Text(
              context.l10n.userProfileTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.bg,
                fontSize: textScaleFactor * 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            top: deviceSizeHeight * 0.250,
            right: 0,
            left: 0,
            child: SizedBox(
              height: deviceSizeHeight * 0.7,
              width: deviceSizeWidth * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  children: <Widget>[
                    _ProfileMenuItem(
                      imagePath: 'assets/images/orders_list.png',
                      label: context.l10n.statisticsLabel,
                      textScaleFactor: textScaleFactor,
                      onTap: () {
                        // TODO: Navigate to statistics screen for driver.
                      },
                    ),
                    _ProfileMenuItem(
                      imagePath: 'assets/images/user_Icon.png',
                      label: context.l10n.personalInfoLabel,
                      textScaleFactor: textScaleFactor,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          CustomerUserInfoScreen.routeName,
                        );
                      },
                    ),
                    _ProfileMenuItem(
                      imagePath: 'assets/images/message_icon.png',
                      label: '',
                      textScaleFactor: textScaleFactor,
                      onTap: () {
                        // TODO: Navigate to driver messages when implemented.
                      },
                    ),
                    _ProfileMenuItem(
                      imagePath: 'assets/images/main_page_request_ic.png',
                      label: context.l10n.requestTabLabel,
                      textScaleFactor: textScaleFactor,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(CollectListScreen.routeName);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    required this.textScaleFactor,
    required this.onTap,
  });

  final String imagePath;
  final String label;
  final double textScaleFactor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.03,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.08),
                blurRadius: 10.1,
                spreadRadius: 10.51,
                offset: const Offset(0, 0),
              )
            ],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: textScaleFactor * 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
