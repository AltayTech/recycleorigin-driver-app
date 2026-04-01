import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:recycleorigindriver/features/statistics_feature/presentation/screens/statistic_list_screen.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/custom_dialog.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/StatisticsScreen';

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isInit = false;

      context.read<AuthBloc>().getToken();

      bool isFirstLogin = context.read<AuthBloc>().state.isFirstLogin;
      if (isFirstLogin) {
        _showLoginDialog(context);
      }
      bool isFirstLogout = context.read<AuthBloc>().state.isFirstLogout;
      if (isFirstLogout) {
        _showLoginDialogExit(context);
      }

      context.read<AuthBloc>().isFirstLogin = false;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _showLoginDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: context.l10n.welcomeTitle,
          buttonText: context.l10n.confirmLabel,
          description: context.l10n.goToProfileDescription,
          image: Image.asset(''),
        ),
      );
    });
  }

  void _showLoginDialogExit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (ctx) => CustomDialog(
          title: context.l10n.dearUserTitle,
          buttonText: context.l10n.confirmLabel,
          description: context.l10n.logoutSuccessDescription,
          image: Image.asset(''),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.statisticsLabel,
          style: TextStyle(
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.08),
                            blurRadius: 10.10,
                            spreadRadius: 10.510,
                            offset: Offset(
                              0,
                              0,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.calendar_today,
                              color: AppTheme.iconColor1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              EnArConvertor()
                                  .replaceArNumber('${Jalali.fromDateTime(
                                DateTime.now(),
                              ).year}/${Jalali.fromDateTime(
                                DateTime.now(),
                              ).month}/${Jalali.fromDateTime(
                                DateTime.now(),
                              ).day}'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.h1,
                                fontSize: textScaleFactor * 16.0,
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.access_time,
                              color: AppTheme.iconColor1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              EnArConvertor().replaceArNumber(
                                  '${DateTime.now().hour}:${DateTime.now().minute}'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.h1,
                                fontSize: textScaleFactor * 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: deviceHeight * 0.7,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return StatisticsListScreen();
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ),
    );
  }
}
