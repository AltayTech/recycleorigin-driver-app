import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/utils/gregorian_date_format.dart';
import 'package:recycleorigindriver/features/statistics_feature/presentation/screens/statistic_list_screen.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/StatisticsScreen';

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
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
                              EnArConvertor.localize(
                                context,
                                GregorianDateFormat.dateYmd(now),
                              ),
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
                              EnArConvertor.localize(
                                context,
                                GregorianDateFormat.timeHm(now),
                              ),
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
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
