import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/core/models/request/waste_cart.dart';
import 'package:recycleorigindriver/core/utils/num_parsing.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

class CollectDetailItem extends StatefulWidget {
  final WasteCart wasteItem;
  final Function function;
  final bool isNotActive;

  const CollectDetailItem({
    super.key,
    required this.wasteItem,
    required this.function,
    required this.isNotActive,
  });

  @override
  State<CollectDetailItem> createState() => _CollectDetailItemState();
}

class _CollectDetailItemState extends State<CollectDetailItem> {
  bool _isInit = true;

  var _isLoading = true;

  int productWeight = 0;

  int productWeightFraction = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;

      productWeight = parseIntOr(
        parseDoubleOr(widget.wasteItem.exact_weight).toStringAsFixed(0),
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> removeItem() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<WastesBloc>().removeWasteCart(widget.wasteItem.waste.id);

    widget.function();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateItem(String exactWeight, bool isAdded) async {
    setState(() {
      _isLoading = true;
    });
    await context.read<WastesBloc>().updateWasteCart(
      widget.wasteItem,
      exactWeight,
      isAdded,
    );

    widget.function();
    setState(() {
      _isLoading = false;
    });
  }

  String getWeight(int kilogram, int gram) {
    final weight = kilogram + gram / 1000;
    return weight.toStringAsFixed(3);
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: deviceWidth * 0.25,
        width: deviceWidth,
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: scheme.surface,
              border: Border.all(color: scheme.outlineVariant, width: 0.3),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  width: deviceWidth * 0.046,
                  height: deviceWidth * 0.046,
                  child: Checkbox(
                    value: widget.wasteItem.isAdded,
                    onChanged: (value) {
                      if (!widget.isNotActive) {
                        if (widget.wasteItem.isAdded) {
                          updateItem(widget.wasteItem.exact_weight, false);
                        } else {
                          updateItem((widget.wasteItem.exact_weight), true);
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      SizedBox(
                        width: constraints.maxWidth * 0.3,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.wasteItem.waste.post_title,
                            style: TextStyle(
                              color: context.primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: textScaleFactor * 18,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          EnArConvertor.localize(
                            context,
                            widget.wasteItem.estimated_weight.toString(),
                          ),
                          style: TextStyle(
                            color: context.primaryText,
                            fontSize: textScaleFactor * 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        height: constraints.maxHeight * 0.8,
                        width: constraints.maxWidth * 0.12,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (!widget.isNotActive) {
                                    productWeightFraction =
                                        productWeightFraction + 50;
                                    if (productWeightFraction >= 1000) {
                                      productWeightFraction =
                                          productWeightFraction - 1000;
                                    }
                                    await context
                                        .read<WastesBloc>()
                                        .updateWasteCart(
                                          widget.wasteItem,
                                          getWeight(
                                            productWeight,
                                            productWeightFraction,
                                          ),
                                          widget.wasteItem.isAdded,
                                        );
                                    widget.function();
                                  }
                                },
                                onDoubleTap: () async {
                                  if (!widget.isNotActive) {
                                    productWeightFraction =
                                        productWeightFraction + 200;
                                    if (productWeightFraction >= 1000) {
                                      productWeightFraction =
                                          productWeightFraction - 1000;
                                    }
                                    await context
                                        .read<WastesBloc>()
                                        .updateWasteCart(
                                          widget.wasteItem,
                                          getWeight(
                                            productWeight,
                                            productWeightFraction,
                                          ),
                                          widget.wasteItem.isAdded,
                                        );
                                    //                                                    changeNumberAnimation(
                                    //                                                        double.parse(getPrice(
                                    //                                                                widget.wasteItem
                                    //                                                                    .prices,
                                    //                                                                widget.wasteItem
                                    //                                                                    .weight)) *
                                    //                                                            widget.wasteItem
                                    //                                                                .weight);
                                    widget.function();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !widget.isNotActive
                                        ? context.brandPrimary.withValues(
                                            alpha: 0.7,
                                          )
                                        : context.secondaryText,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: context.pageBackground,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  EnArConvertor.localize(
                                    context,
                                    (productWeightFraction / 1000)
                                        .toStringAsFixed(3),
                                  ),
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!widget.isNotActive) {
                                    productWeightFraction =
                                        productWeightFraction - 50;
                                    if (productWeightFraction < 0) {
                                      productWeightFraction = 0;
                                    }

                                    context.read<WastesBloc>().updateWasteCart(
                                      widget.wasteItem,
                                      getWeight(
                                        productWeight,
                                        productWeightFraction,
                                      ),
                                      widget.wasteItem.isAdded,
                                    );
                                    //                                                        changeNumberAnimation(
                                    //                                                            double.parse(getPrice(
                                    //                                                                    widget
                                    //                                                                        .wasteItem
                                    //                                                                        .prices,
                                    //                                                                    widget
                                    //                                                                        .wasteItem
                                    //                                                                        .weight)) *
                                    //                                                                widget.wasteItem
                                    //                                                                    .weight);

                                    widget.function();
                                  }
                                },
                                onDoubleTap: () async {
                                  if (!widget.isNotActive) {
                                    productWeightFraction =
                                        productWeightFraction - 20;
                                    if (productWeightFraction < 0) {
                                      productWeightFraction = 0;
                                    }

                                    context.read<WastesBloc>().updateWasteCart(
                                      widget.wasteItem,
                                      getWeight(
                                        productWeight,
                                        productWeightFraction,
                                      ),
                                      widget.wasteItem.isAdded,
                                    );
                                    //                                                        changeNumberAnimation(
                                    //                                                            double.parse(getPrice(
                                    //                                                                    widget
                                    //                                                                        .wasteItem
                                    //                                                                        .prices,
                                    //                                                                    widget
                                    //                                                                        .wasteItem
                                    //                                                                        .weight)) *
                                    //                                                                widget.wasteItem
                                    //                                                                    .weight);

                                    widget.function();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !widget.isNotActive
                                        ? context.brandPrimary.withValues(
                                            alpha: 0.7,
                                          )
                                        : context.secondaryText,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: context.pageBackground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * 0.8,
                        width: constraints.maxWidth * 0.12,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (!widget.isNotActive) {
                                    productWeight = productWeight + 1;

                                    await context
                                        .read<WastesBloc>()
                                        .updateWasteCart(
                                          widget.wasteItem,
                                          getWeight(
                                            productWeight,
                                            productWeightFraction,
                                          ),
                                          widget.wasteItem.isAdded,
                                        );
                                    //                                                    changeNumberAnimation(
                                    //                                                        double.parse(getPrice(
                                    //                                                                widget.wasteItem
                                    //                                                                    .prices,
                                    //                                                                widget.wasteItem
                                    //                                                                    .weight)) *
                                    //                                                            widget.wasteItem
                                    //                                                                .weight);
                                    widget.function();
                                  }
                                },
                                onDoubleTap: () async {
                                  if (!widget.isNotActive) {
                                    productWeight = productWeight + 10;

                                    await context
                                        .read<WastesBloc>()
                                        .updateWasteCart(
                                          widget.wasteItem,
                                          getWeight(
                                            productWeight,
                                            productWeightFraction,
                                          ),
                                          widget.wasteItem.isAdded,
                                        );
                                    //                                                    changeNumberAnimation(
                                    //                                                        double.parse(getPrice(
                                    //                                                                widget.wasteItem
                                    //                                                                    .prices,
                                    //                                                                widget.wasteItem
                                    //                                                                    .weight)) *
                                    //                                                            widget.wasteItem
                                    //                                                                .weight);
                                    widget.function();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !widget.isNotActive
                                        ? context.brandPrimary
                                        : context.secondaryText,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: context.pageBackground,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  EnArConvertor.localize(
                                    context,
                                    parseDoubleOr(
                                      widget.wasteItem.exact_weight,
                                    ).toStringAsFixed(0),
                                  ),
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!widget.isNotActive) {
                                    if (productWeight > 1) {
                                      productWeight = productWeight - 1;

                                      context
                                          .read<WastesBloc>()
                                          .updateWasteCart(
                                            widget.wasteItem,
                                            getWeight(
                                              productWeight,
                                              productWeightFraction,
                                            ),
                                            widget.wasteItem.isAdded,
                                          );
                                      //                                                        changeNumberAnimation(
                                      //                                                            double.parse(getPrice(
                                      //                                                                    widget
                                      //                                                                        .wasteItem
                                      //                                                                        .prices,
                                      //                                                                    widget
                                      //                                                                        .wasteItem
                                      //                                                                        .weight)) *
                                      //                                                                widget.wasteItem
                                      //                                                                    .weight);
                                    }
                                    widget.function();
                                  }
                                },
                                onDoubleTap: () async {
                                  if (!widget.isNotActive) {
                                    if (productWeight > 10) {
                                      productWeight = productWeight - 10;

                                      context
                                          .read<WastesBloc>()
                                          .updateWasteCart(
                                            widget.wasteItem,
                                            getWeight(
                                              productWeight,
                                              productWeightFraction,
                                            ),
                                            widget.wasteItem.isAdded,
                                          );
                                      //                                                        changeNumberAnimation(
                                      //                                                            double.parse(getPrice(
                                      //                                                                    widget
                                      //                                                                        .wasteItem
                                      //                                                                        .prices,
                                      //                                                                    widget
                                      //                                                                        .wasteItem
                                      //                                                                        .weight)) *
                                      //                                                                widget.wasteItem
                                      //                                                                    .weight);
                                    }
                                    widget.function();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !widget.isNotActive
                                        ? context.brandPrimary
                                        : context.secondaryText,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: context.pageBackground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.05),
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
                                  color: index.isEven
                                      ? Colors.grey
                                      : Colors.grey,
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
      ),
    );
  }
}
