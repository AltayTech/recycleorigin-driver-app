import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';

import 'package:recycleorigindriver/core/models/request/price_weight.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/utils/num_parsing.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class CollectDetailsCollectItem extends StatefulWidget {
  final Collect collectItem;

  const CollectDetailsCollectItem({super.key, required this.collectItem});

  @override
  State<CollectDetailsCollectItem> createState() =>
      _CollectDetailsCollectItemState();
}

class _CollectDetailsCollectItemState extends State<CollectDetailsCollectItem> {
  bool _isInit = true;

  var _isLoading = true;

  int productWeight = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;

      productWeight = parseIntOr(widget.collectItem.estimated_weight);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  String getPrice(List<PriceWeight> prices, int weight) {
    String price = '0';

    for (int i = 0; i < prices.length; i++) {
      if (weight > parseIntOr(prices[i].weight)) {
        price = prices[i].price;
      } else {
        price = prices[i].price;
        break;
      }
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: deviceWidth * 0.30,
        width: deviceWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: scheme.surface,
          border: Border.all(color: scheme.outlineVariant, width: 0.3),
        ),
        child: LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.collectItem.waste.post_title,
                            style: TextStyle(
                              color: context.primaryText,
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 16,
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                l10n.collectTotalWeightColon,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: textScaleFactor * 12,
                                ),
                              ),
                              Text(
                                EnArConvertor.localize(
                                  context,
                                  widget.collectItem.estimated_weight
                                      .toString(),
                                ),
                                style: TextStyle(
                                  color: context.primaryText,
                                  fontSize: textScaleFactor * 16,
                                ),
                              ),
                              Text(
                                ' ${l10n.kilogramLabel} ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: textScaleFactor * 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            l10n.collectPerKgColon,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: textScaleFactor * 12,
                            ),
                          ),
                          Text(
                            EnArConvertor.localize(
                              context,
                              currencyFormat.format(
                                parseDoubleOr(
                                  widget.collectItem.estimated_price,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              color: context.primaryText,
                              fontSize: textScaleFactor * 16,
                            ),
                          ),
                          Text(
                            ' ${l10n.tomanLabel} ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: textScaleFactor * 12,
                            ),
                          ),
                          Spacer(),
                          Text(
                            l10n.collectTotalPriceColon,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: textScaleFactor * 12,
                            ),
                          ),
                          Text(
                            EnArConvertor.localize(
                              context,
                              currencyFormat.format(
                                parseDoubleOr(
                                  widget.collectItem.estimated_price,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              color: context.primaryText,
                              fontSize: textScaleFactor * 18,
                            ),
                          ),
                          Text(
                            ' ${l10n.tomanLabel} ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: textScaleFactor * 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index.isEven ? Colors.grey : Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
