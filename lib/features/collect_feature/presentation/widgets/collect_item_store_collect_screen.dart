import 'package:flutter/material.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';

import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

class CollectItemStoreCollectsScreen extends StatelessWidget {
  const CollectItemStoreCollectsScreen({super.key});

  Widget getStatusIcon(BuildContext context, String statusSlug) {
    if (statusSlug == 'delivery_done') {
      return Icon(Icons.check_circle, color: context.brandPrimary);
    }
    return Icon(
      Icons.access_time,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final collect = Provider.of<DeliveryWasteItem>(context, listen: false);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: widthDevice * 0.25,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return InkWell(
              onTap: () {
                //                Navigator.of(context).pushNamed(
                //                  DeliveryDetailScreen.routeName,
                //                  arguments: collect.id,
                //                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: scheme.outlineVariant, width: 0.3),
                ),
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    bottom: 4,
                                  ),
                                  child: Icon(
                                    Icons.date_range,
                                    color: context.brandPrimary,
                                  ),
                                ),
                                Text(
                                  collect.delivery_date,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 15.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: getStatusIcon(
                                context,
                                collect.status.slug,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 30,
                                      left: 4,
                                    ),
                                    child: Text(
                                      EnArConvertor.localize(
                                        context,
                                        collect.total_collects_weight.estimated,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: context.primaryText,
                                        fontSize: textScaleFactor * 15.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    context.l10n.kilogramLabel,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.secondaryText,
                                      fontSize: textScaleFactor * 10.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 15.0,
                                    ),
                                  ),
                                  Text(
                                    ' ${context.l10n.tomanLabel}',
                                    maxLines: 1,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: context.secondaryText,
                                      fontSize: textScaleFactor * 11.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                collect.status.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.primaryText,
                                  fontSize: textScaleFactor * 12.0,
                                ),
                              ),
                            ),
                          ],
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
