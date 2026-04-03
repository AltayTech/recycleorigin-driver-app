import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';

class CollectItemCollectsScreen extends StatelessWidget {
  Widget getStatusIcon(String statusSlug, {String requestStatusKey = ''}) {
    if (requestStatusKey == 'pending_driver_acceptance') {
      return Icon(
        Icons.hourglass_top_rounded,
        color: AppTheme.accent,
      );
    }
    if (requestStatusKey == 'driver_accepted' ||
        requestStatusKey == 'in_progress') {
      return Icon(
        Icons.how_to_reg_rounded,
        color: AppTheme.primary,
      );
    }
    if (requestStatusKey == 'pending_assignment') {
      return Icon(
        Icons.person_search_rounded,
        color: AppTheme.grey,
      );
    }

    Widget icon = Icon(
      Icons.timer,
      color: AppTheme.accent,
//      size: 35,
    );

    if (statusSlug == 'register') {
      icon = Icon(
        Icons.beenhere,
        color: AppTheme.accent,
//        size: 25,
      );
    } else if (statusSlug == 'cancel') {
      icon = Icon(
        Icons.cancel,
        color: AppTheme.grey,
//        size: 35,
      );
    } else if (statusSlug == 'collected') {
      icon = Icon(
        Icons.check_circle,
        color: AppTheme.primary,
//        size: 35,
      );
    } else if (statusSlug == 'not-accessed') {
      icon = Icon(
        Icons.cancel,
        color: AppTheme.grey,
//        size: 35,
      );
    } else {
      icon = Icon(
        Icons.drive_eta,
        color: AppTheme.accent,
//        size: 35,
      );
    }

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final l10n = context.l10n;
    final collect = Provider.of<RequestWasteItem>(context, listen: false);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: widthDevice * 0.30,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  CollectDetailScreen.routeName,
                  arguments: collect.id,
                );
              },
              child: Container(
                decoration: AppTheme.listItemBox.copyWith(
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.white)),
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 6, left: 4),
                                                  child: Icon(
                                                    Icons.date_range,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Text(
                                                      EnArConvertor.localize(
                                                        context,
                                                        collect
                                                            .collect_date.day,
                                                      ),
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        color: AppTheme.black,
                                                        fontSize:
                                                            textScaleFactor *
                                                                12.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 6, left: 4),
                                                  child: Icon(
                                                    Icons.access_time,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Text(
                                                    EnArConvertor.localize(
                                                      context,
                                                      collect.collect_date.time,
                                                    ),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      color: AppTheme.black,
                                                      fontSize:
                                                          textScaleFactor *
                                                              14.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: getStatusIcon(
                                              collect.status.slug,
                                              requestStatusKey:
                                                  collect.requestStatusKey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 28, left: 8),
                                                  child: Text(
                                                    EnArConvertor.localize(
                                                      context,
                                                      collect
                                                          .total_collects_weight
                                                          .estimated,
                                                    ),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppTheme.black,
                                                      fontSize:
                                                          textScaleFactor *
                                                              14.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  l10n.kilogramLabel,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize:
                                                        textScaleFactor * 10.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  EnArConvertor.localize(
                                                    context,
                                                    currencyFormat.format(
                                                      double.parse(
                                                        collect
                                                            .total_collects_price
                                                            .estimated,
                                                      ),
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: AppTheme.black,
                                                    fontSize:
                                                        textScaleFactor * 14.0,
                                                  ),
                                                ),
                                                Text(
                                                  ' ${l10n.tomanLabel}',
                                                  maxLines: 1,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize:
                                                        textScaleFactor * 11.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              collect.requestStatusDisplay(
                                                context.l10n,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.black,
                                                fontSize:
                                                    textScaleFactor * 13.0,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, bottom: 8),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                collect.address_data.address,
                                maxLines: 1,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontSize: textScaleFactor * 12.0,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
