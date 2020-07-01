import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../models/request/request_waste_item.dart';
import '../provider/app_theme.dart';
import '../screens/collect_detail_screen.dart';
import 'en_to_ar_number_convertor.dart';

class CollectItemCollectsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var heightDevice = MediaQuery.of(context).size.height;
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final collect = Provider.of<RequestWasteItem>(context, listen: false);
    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: widthDevice * 0.29,
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
                decoration: AppTheme.listItemBox,
                height: constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Icon(
                                          Icons.date_range,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          collect.collect_date.day,
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 12.0,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Expanded(
                                        child: Icon(
                                          Icons.av_timer,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          collect.collect_date.time,
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: AppTheme.black,
                                            fontFamily: 'Iransans',
                                            fontSize: textScaleFactor * 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            EnArConvertor().replaceArNumber(
                                                collect.total_collects_weight.estimated),
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 16.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'کیلوگرم',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 10.0,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            EnArConvertor().replaceArNumber(
                                                currencyFormat
                                                    .format(double.parse(
                                                        collect.total_collects_price.estimated))
                                                    .toString()),
                                            maxLines: 1,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: AppTheme.black,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 14.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ' تومان',
                                            maxLines: 1,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 11.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                      child: Icon(
                                        Icons.timer,
                                        color: AppTheme.primary,
                                      )),
                                  Spacer(),
                                  Expanded(
                                    child: Text(
                                      collect.status.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: AppTheme.black,
                                        fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 13.0,
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
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right:10.0,left: 8,bottom: 8),
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
                              fontFamily: 'Iransans',
                              fontSize: textScaleFactor * 12.0,
                            ),
                          ),
                          Spacer(),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
