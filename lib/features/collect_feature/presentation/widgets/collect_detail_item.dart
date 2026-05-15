import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';

import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

class CollectDetailItem extends StatefulWidget {
  final WasteCart wasteItem;
  final Function function;
  final bool isNotActive;

  CollectDetailItem({
    required this.wasteItem,
    required this.function,
    required this.isNotActive,
  });

  @override
  _CollectDetailItemState createState() => _CollectDetailItemState();
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

      productWeight = int.parse(
          double.parse(widget.wasteItem.exact_weight).toStringAsFixed(0));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> removeItem() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<WastesBloc>().removeWasteCart(
          widget.wasteItem.pasmand.id,
        );

    widget.function();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateItem(String exactWeight, bool isAdded) async {
    setState(() {
      _isLoading = true;
    });
    await context
        .read<WastesBloc>()
        .updateWasteCart(widget.wasteItem, exactWeight, isAdded);

    widget.function();
    setState(() {
      _isLoading = false;
    });
  }

  String getWeight(int kilogram, int gram) {
    String totalWeight = '0';
    print(totalWeight);
    double weight = double.parse(kilogram.toString()) +
        double.parse(gram.toString()) / 1000;
    print(weight.toString());

    totalWeight = weight.toStringAsFixed(3);
    print(totalWeight.toString());

    return totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: deviceWidth * 0.25,
        width: deviceWidth,
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            decoration: AppTheme.listItemBox,
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
                      Container(
                        width: constraints.maxWidth * 0.3,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.wasteItem.pasmand.post_title != null
                                ? widget.wasteItem.pasmand.post_title
                                : context.l10n.noneLabel,
                            style: TextStyle(
                              color: AppTheme.black,
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
                            color: AppTheme.black,
                            fontSize: textScaleFactor * 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                      Container(
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
                                          getWeight(productWeight,
                                              productWeightFraction),
                                          widget.wasteItem.isAdded);
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
                                          getWeight(productWeight,
                                              productWeightFraction),
                                          widget.wasteItem.isAdded);
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
                                        ? AppTheme.accent.withOpacity(0.7)
                                        : AppTheme.grey,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.bg,
                                  )),
                            )),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  EnArConvertor.localize(
                                    context,
                                    (double.parse(productWeightFraction
                                                .toString()) /
                                            1000)
                                        .toStringAsFixed(3),
                                  ),
                                  style: TextStyle(
                                    color: AppTheme.black,
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
                                        getWeight(productWeight,
                                            productWeightFraction),
                                        widget.wasteItem.isAdded);
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
                                        getWeight(productWeight,
                                            productWeightFraction),
                                        widget.wasteItem.isAdded);
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
                                        ? AppTheme.accent.withOpacity(0.7)
                                        : AppTheme.grey,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: AppTheme.bg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
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
                                          getWeight(productWeight,
                                              productWeightFraction),
                                          widget.wasteItem.isAdded);
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
                                          getWeight(productWeight,
                                              productWeightFraction),
                                          widget.wasteItem.isAdded);
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
                                        ? AppTheme.accent
                                        : AppTheme.grey,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: AppTheme.bg,
                                  )),
                            )),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  EnArConvertor.localize(
                                    context,
                                    double.parse(widget.wasteItem.exact_weight)
                                        .toStringAsFixed(0),
                                  ),
                                  style: TextStyle(
                                    color: AppTheme.black,
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
                                      print('productCount' +
                                          productWeight.toString());

                                      context
                                          .read<WastesBloc>()
                                          .updateWasteCart(
                                              widget.wasteItem,
                                              getWeight(productWeight,
                                                  productWeightFraction),
                                              widget.wasteItem.isAdded);
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
                                      print('productCount' +
                                          productWeight.toString());

                                      context
                                          .read<WastesBloc>()
                                          .updateWasteCart(
                                              widget.wasteItem,
                                              getWeight(productWeight,
                                                  productWeightFraction),
                                              widget.wasteItem.isAdded);
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
                                        ? AppTheme.accent
                                        : AppTheme.grey,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: AppTheme.bg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth * 0.05,
                      )
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
                            : Container()))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
