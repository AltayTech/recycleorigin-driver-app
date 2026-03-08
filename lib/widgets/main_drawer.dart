import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/screens/customer_info/customer_user_info_screen.dart';
import 'package:recycleorigindriver/screens/statistics_screen.dart';

import '../l10n/l10n.dart';
import '../provider/auth.dart';
import '../provider/customer_info.dart';
import '../screens/about_us_screen.dart';
import '../screens/contact_with_us_screen.dart';
import '../screens/customer_info/login_screen.dart';
import '../screens/guide_screen.dart';
import '../screens/navigation_bottom_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    Color textColor = Colors.white;
    Color iconColor = Colors.white38;
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      child: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            Wrap(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: deviceHeight * 0.25,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/main_page_header.png',
                        fit: BoxFit.cover,
                      ),
                    ),
//                      Container(
//                        width: double.infinity,
//                        height: deviceHeight * 0.25,
//                        padding: EdgeInsets.all(20),
//                        alignment: Alignment.center,
//                        color: Colors.purpleAccent.withOpacity(0.1),
//                        child: Padding(
//                          padding: const EdgeInsets.only(top: 20.0),
//                          child: Text(
//                            'نسخه آزمایشی فروشگاه \n همراه ساتل',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w400,
//                                fontSize: 24,
//                                height: 2,
//                                fontFamily: 'BFarnaz',
//                                color: AppTheme.bg),
//                            textAlign: TextAlign.center,
//                          ),
//                        ),
//                      ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Consumer<Auth>(
                  builder: (_, auth, ch) => ListTile(
                    title: Text(
                      auth.isAuth
                          ? context.l10n.userProfileLabel
                          : context.l10n.loginLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    trailing: Icon(
                      Icons.account_circle,
                      color: iconColor,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      auth.isAuth
                          ? Navigator.of(context)
                              .pushNamed(CustomerUserInfoScreen.routeName)
                          : Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                    },
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                Container(
                  height: deviceHeight * 0.63,
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            context.l10n.homeTabLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.home,
                            color: iconColor,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                NavigationBottomScreen.routeName,
                                (Route<dynamic> route) => false);
//                              Navigator.of(context)
//                                  .pushNamed(NavigationBottomScreen.routeName);
                          },
                        ),
                        ListTile(
                          title: Text(
                            context.l10n.statisticsLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.format_list_numbered,
                            color: iconColor,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context)
                                .pushNamed(StatisticsScreen.routeName);
                          },
                        ),
                        ListTile(
                          title: Text(
                            context.l10n.guideLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.help,
                            color: iconColor,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context)
                                .pushNamed(GuideScreen.routeName);
                          },
                        ),
                        ListTile(
                          title: Text(
                            context.l10n.contactUsLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.contact_phone,
                            color: iconColor,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context)
                                .pushNamed(ContactWithUs.routeName);
                          },
                        ),
                        ListTile(
                          title: Text(
                            context.l10n.aboutUsLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.account_balance,
                            color: iconColor,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context)
                                .pushNamed(AboutUsScreen.routeName);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                        ListTile(
                          title: Text(
                            context.l10n.logoutLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          trailing: Icon(
                            Icons.power_settings_new,
                            color: Colors.red,
                          ),
                          onTap: () async {
                            Provider.of<CustomerInfo>(context, listen: false)
                                .driver = Provider.of<CustomerInfo>(context,
                                    listen: false)
                                .driver_zero;
                            await Provider.of<Auth>(context, listen: false)
                                .removeToken();
                            Provider.of<Auth>(context, listen: false)
                                .isFirstLogout = true;
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .pushNamed(NavigationBottomScreen.routeName);
                          },
                        ),
//                          Container(
//                            height: 20,
//                            color: Colors.black54,
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Text(
//                                  'تبریزاپس',
//                                  textAlign: TextAlign.center,
//                                  style: TextStyle(
//                                    fontFamily: 'Iransans',
//                                    color: Colors.green,
//                                    fontSize: textScaleFactor * 11.0,
//                                  ),
//                                ),
//                                Text(
//                                  'طراحی شده توسط',
//                                  textAlign: TextAlign.center,
//                                  style: TextStyle(
//                                    fontFamily: 'Iransans',
//                                    color: textColor,
//                                    fontSize: textScaleFactor * 11.0,
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
