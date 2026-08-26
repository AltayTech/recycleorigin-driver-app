import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class StatisticItemStatisticsScreen extends StatelessWidget {
  final Color headColor;
  final String title;
  final String price;
  final String weight;
  final String number;

  const StatisticItemStatisticsScreen({super.key, 
    required this.headColor,
    required this.title,
    required this.price,
    required this.weight,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    var heightDevice = MediaQuery.of(context).size.height;
    var widthDevice = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final collect = Provider.of<RequestWasteItem>(context, listen: false);

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: widthDevice * 0.3,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.primaryText,
                      fontSize: textScaleFactor * 15.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CollectDetailScreen.routeName,
                      arguments: collect.id,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: headColor, width: 1)),
                    height: constraints.maxHeight * 0.650,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                color: headColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    l10n.priceTomanLabel,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 12.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    l10n.weightKgLabel,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 12.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    l10n.countLabel,
                                    maxLines: 1,
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
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  price,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 16.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  weight,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 16.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  number,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 16.0,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
