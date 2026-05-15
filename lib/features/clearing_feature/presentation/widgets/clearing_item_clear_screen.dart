import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/core/models/clearing.dart';

import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

class ClearingItemClearScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var heightDevice = MediaQuery.of(context).size.height;
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final transaction = Provider.of<Clearing>(context, listen: false);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: widthDevice * 0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppTheme.white,
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return InkWell(
              onTap: () {
//              Provider.of<Products>(context, listen: false).item =
//                  Provider.of<Products>(context, listen: false).itemZero;
//              Navigator.of(context).pushNamed(
//                ProductDetailScreen.routeName,
//                arguments: transaction.id,
//              );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      transaction.status.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: textScaleFactor * 14.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      EnArConvertor.localize(
                        context,
                        currencyFormat.format(
                          double.parse(transaction.money),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: textScaleFactor * 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
