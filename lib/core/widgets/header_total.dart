import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';

import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:intl/intl.dart' as intl;

class HeaderTotal extends StatelessWidget {
  HeaderTotal({
    required this.totalWeight,
    required this.totalPrice,
    required this.totalNumber,
    required this.totalPriceController,
    required this.totalPriceAnimation,
  });

  final double totalWeight;
  final double totalPrice;
  final int totalNumber;
  AnimationController totalPriceController;
  Animation<double> totalPriceAnimation;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    return LayoutBuilder(
      builder: (_, constraint) => Container(
        height: deviceWidth * 0.35,
        decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey, width: 0.2)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Image.asset(
                      'assets/images/main_page_request_ic.png',
                      height: deviceWidth * 0.09,
                      width: deviceWidth * 0.09,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        EnArConvertor.localize(
                          context,
                          totalNumber.toString(),
                        ),
                        style: TextStyle(
                          color: AppTheme.h1,
                          fontSize: textScaleFactor * 18,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.countLabel,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: textScaleFactor * 12,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Image.asset(
                      'assets/images/waste_cart_price_ic.png',
                      height: deviceWidth * 0.09,
                      width: deviceWidth * 0.09,
                      color: Colors.yellow[600],
                    ),
                    AnimatedBuilder(
                      animation: totalPriceAnimation,
                      builder: (context, child) {
                        return Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: Text(
                            totalPrice.toString().isNotEmpty
                                ? EnArConvertor.localize(
                                    context,
                                    currencyFormat.format(
                                      double.parse(
                                        totalPriceAnimation.value
                                            .toStringAsFixed(0),
                                      ),
                                    ),
                                  )
                                : EnArConvertor.localize(context, '0'),
                            style: TextStyle(
                              color: AppTheme.h1,
                              fontSize: textScaleFactor * 18,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      context.l10n.tomanLabel,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: textScaleFactor * 12,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Image.asset(
                      'assets/images/waste_cart_weight_ic.png',
                      height: deviceWidth * 0.09,
                      width: deviceWidth * 0.09,
                    ),
//                                      Icon(
//                                        Icons.av_timer,
//                                        color: Colors.blue,
//                                        size: 40,
//                                      ),
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          EnArConvertor.localize(
                            context,
                            totalWeight.toString(),
                          ),
                          style: TextStyle(
                            color: AppTheme.h1,
                            fontSize: textScaleFactor * 18,
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        context.l10n.kilogramLabel,
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: textScaleFactor * 12,
                        ),
                      ),
                    ),
                    Spacer(),
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
