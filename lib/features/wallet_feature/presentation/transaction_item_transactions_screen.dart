import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/core/models/transaction.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/localization/transaction_operation_labels.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class TransactionItemTransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    var heightDevice = MediaQuery.of(context).size.height;
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final transaction = Provider.of<Transaction>(context, listen: false);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: widthDevice * 0.18,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        localizedTransactionOperation(
                          l10n,
                          transaction.operation,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: textScaleFactor * 15.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        transaction.transaction_type.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: textScaleFactor * 15.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        EnArConvertor.localize(
                          context,
                          currencyFormat.format(
                            double.parse(transaction.money).roundToDouble(),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isWithdrawalOperation(transaction.operation)
                              ? Colors.red
                              : AppTheme.primary,
                          fontSize: textScaleFactor * 17.0,
                        ),
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
