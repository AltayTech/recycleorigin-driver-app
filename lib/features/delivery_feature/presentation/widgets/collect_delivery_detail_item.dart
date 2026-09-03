import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/utils/num_parsing.dart';

import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';

class CollectDeliveryDetailItem extends StatefulWidget {
  final Collect wasteItem;
  final Function function;

  const CollectDeliveryDetailItem({
    super.key,
    required this.wasteItem,
    required this.function,
  });

  @override
  State<CollectDeliveryDetailItem> createState() =>
      _CollectDeliveryDetailItemState();
}

class _CollectDeliveryDetailItemState extends State<CollectDeliveryDetailItem>
    with TickerProviderStateMixin {
  bool _isInit = true;

  var _isLoading = true;

  double productWeight = 0;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;

      productWeight = parseDoubleOr(widget.wasteItem.exact_weight);
      //      changeNumberAnimation(double.parse(
      //              getPrice(widget.wasteItem.prices, widget.wasteItem.weight)) *
      //          widget.wasteItem.weight);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //  Future<void> removeItem() async {
  //    setState(() {
  //      _isLoading = true;
  //    });
  //    await Provider.of<Wastes>(context, listen: false).removeWasteCart(
  //      widget.wasteItem.waste.id,
  //    );
  //
  //    widget.function();
  //    setState(() {
  //      _isLoading = false;
  //    });
  //  }

  //  Future<void> updateItem(String exactWeight, bool isAdded) async {
  //    setState(() {
  //      _isLoading = true;
  //    });
  //    await Provider.of<Wastes>(context, listen: false)
  //        .updateWasteCart(widget.wasteItem, exactWeight, isAdded);
  //
  //    widget.function();
  //    setState(() {
  //      _isLoading = false;
  //    });
  //  }

  //  String getPrice(List<PriceWeight> prices, int weight) {
  //    String price = '0';
  //
  //    for (int i = 0; i < prices.length; i++) {
  //      if (weight > int.parse(prices[i].weight)) {
  //        price = prices[i].price;
  //      } else {
  //        price = prices[i].price;
  //        break;
  //      }
  //    }
  //    return price;
  //  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = _controller;
    changeNumberAnimation(parseDoubleOr(widget.wasteItem.estimated_price));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeNumberAnimation(double newValue) {
    setState(() {
      _animation = Tween<double>(
        begin: _animation.value,
        end: newValue,
      ).animate(CurvedAnimation(curve: Curves.ease, parent: _controller));
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: deviceWidth * 0.25,
        width: deviceWidth,
        child: LayoutBuilder(
          builder: (_, constraints) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.3,
              ),
            ),
            child: Stack(
              children: <Widget>[
                //                Positioned(
                //                  top: 0,
                //                  right: 0,
                //                  width: deviceWidth * 0.046,
                //                  height: deviceWidth * 0.046,
                //                  child: Checkbox(
                //                    value: widget.wasteItem.isAdded,
                //                    onChanged: (value) {
                //                      if (widget.wasteItem.isAdded) {
                //                        updateItem(widget.wasteItem.exact_weight, false);
                //                      } else {
                //                        updateItem((widget.wasteItem.exact_weight), true);
                //                      }
                //                    },
                //                  ),
                //                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            EnArConvertor.localize(
                              context,
                              widget.wasteItem.estimated_weight.toString(),
                            ),
                            style: TextStyle(
                              color: context.primaryText,
                              fontSize: textScaleFactor * 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Text(
                              widget.wasteItem.estimated_price.isNotEmpty
                                  ? EnArConvertor.localize(
                                      context,
                                      currencyFormat.format(
                                        _animation.value,
                                      ),
                                    )
                                  : EnArConvertor.localize(context, '0'),
                              style: TextStyle(
                                color: context.primaryText,
                                fontSize: textScaleFactor * 18,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                      //                      Container(
                      //                        height: constraints.maxHeight * 0.8,
                      //                        width: constraints.maxWidth * 0.12,
                      //                        child: Column(
                      //                          mainAxisAlignment: MainAxisAlignment.center,
                      //                          crossAxisAlignment: CrossAxisAlignment.center,
                      //                          children: <Widget>[
                      //                            Expanded(
                      //                                child: InkWell(
                      //                                  onTap: () async {
                      //                                    productWeight = productWeight + 1;
                      //
                      //                                    await Provider.of<Wastes>(context,
                      //                                        listen: false)
                      //                                        .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                    changeNumberAnimation(
                      ////                                                        double.parse(getPrice(
                      ////                                                                widget.wasteItem
                      ////                                                                    .prices,
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight)) *
                      ////                                                            widget.wasteItem
                      ////                                                                .weight);
                      //                                    widget.function();
                      //                                  },
                      //                                  onDoubleTap: () async {
                      //                                    productWeight = productWeight + 10;
                      //
                      //                                    await Provider.of<Wastes>(context,
                      //                                        listen: false)
                      //                                        .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                    changeNumberAnimation(
                      ////                                                        double.parse(getPrice(
                      ////                                                                widget.wasteItem
                      ////                                                                    .prices,
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight)) *
                      ////                                                            widget.wasteItem
                      ////                                                                .weight);
                      //                                    widget.function();
                      //                                  },
                      //                                  child: Container(
                      //                                      decoration: BoxDecoration(
                      //                                        shape: BoxShape.circle,
                      //                                        color: AppTheme.accent,
                      //                                      ),
                      //                                      child: Icon(
                      //                                        Icons.add,
                      //                                        color: AppTheme.bg,
                      //                                      )),
                      //                                )),
                      //                            Expanded(
                      //                              child: Padding(
                      //                                padding: const EdgeInsets.only(top: 3.0),
                      //                                child: Text(
                      //                                  EnArConvertor()
                      //                                      .replaceArNumber(widget
                      //                                      .wasteItem.exact_weight
                      //                                      .toString())
                      //                                      .toString(),
                      //                                  style: TextStyle(
                      //                                    color: context.primaryText,
                      //                                    //                                    fontSize: textScaleFactor * 14,
                      //                                  ),
                      //                                  textAlign: TextAlign.center,
                      //                                ),
                      //                              ),
                      //                            ),
                      //                            Expanded(
                      //                              child: InkWell(
                      //                                onTap: () {
                      //                                  if (productWeight > 1) {
                      //                                    productWeight = productWeight - 1;
                      //                                    print('productCount' +
                      //                                        productWeight.toString());
                      //
                      //                                    Provider.of<Wastes>(context, listen: false)
                      //                                        .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                        changeNumberAnimation(
                      ////                                                            double.parse(getPrice(
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .prices,
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .weight)) *
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight);
                      //                                  }
                      //                                  widget.function();
                      //                                },
                      //                                onDoubleTap: () async {
                      //                                  if (productWeight > 10) {
                      //                                    productWeight = productWeight - 10;
                      //                                    print('productCount' +
                      //                                        productWeight.toString());
                      //
                      //                                    Provider.of<Wastes>(context, listen: false)
                      //                                        .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                        changeNumberAnimation(
                      ////                                                            double.parse(getPrice(
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .prices,
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .weight)) *
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight);
                      //                                  }
                      //                                  widget.function();
                      //                                },
                      //                                child: Container(
                      //                                  decoration: BoxDecoration(
                      //                                    shape: BoxShape.circle,
                      //                                    color: AppTheme.accent,
                      //                                  ),
                      //                                  child: Icon(
                      //                                    Icons.remove,
                      //                                    color: AppTheme.bg,
                      //                                  ),
                      //                                ),
                      //                              ),
                      //                            ),
                      //                          ],
                      //                        ),
                      //                      ),
                      //                      Container(
                      //                        height: constraints.maxHeight * 0.8,
                      //                        width: constraints.maxWidth * 0.12,
                      //                        child: Column(
                      //                          mainAxisAlignment: MainAxisAlignment.center,
                      //                          crossAxisAlignment: CrossAxisAlignment.center,
                      //                          children: <Widget>[
                      //                            Expanded(
                      //                                child: InkWell(
                      //                              onTap: () async {
                      //                                productWeight = productWeight + 1;
                      //
                      //                                await Provider.of<Wastes>(context,
                      //                                        listen: false)
                      //                                    .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                    changeNumberAnimation(
                      ////                                                        double.parse(getPrice(
                      ////                                                                widget.wasteItem
                      ////                                                                    .prices,
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight)) *
                      ////                                                            widget.wasteItem
                      ////                                                                .weight);
                      //                                widget.function();
                      //                              },
                      //                              onDoubleTap: () async {
                      //                                productWeight = productWeight + 10;
                      //
                      //                                await Provider.of<Wastes>(context,
                      //                                        listen: false)
                      //                                    .updateWasteCart(
                      //                                        widget.wasteItem,
                      //                                        productWeight.toString(),
                      //                                        widget.wasteItem.isAdded);
                      ////                                                    changeNumberAnimation(
                      ////                                                        double.parse(getPrice(
                      ////                                                                widget.wasteItem
                      ////                                                                    .prices,
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight)) *
                      ////                                                            widget.wasteItem
                      ////                                                                .weight);
                      //                                widget.function();
                      //                              },
                      //                              child: Container(
                      //                                  decoration: BoxDecoration(
                      //                                    shape: BoxShape.circle,
                      //                                    color: AppTheme.accent,
                      //                                  ),
                      //                                  child: Icon(
                      //                                    Icons.add,
                      //                                    color: AppTheme.bg,
                      //                                  )),
                      //                            )),
                      //                            Expanded(
                      //                              child: Padding(
                      //                                padding: const EdgeInsets.only(top: 3.0),
                      //                                child: Text(
                      //                                  EnArConvertor()
                      //                                      .replaceArNumber(widget
                      //                                          .wasteItem.exact_weight
                      //                                          .toString())
                      //                                      .toString(),
                      //                                  style: TextStyle(
                      //                                    color: context.primaryText,
                      //                                    //                                    fontSize: textScaleFactor * 14,
                      //                                  ),
                      //                                  textAlign: TextAlign.center,
                      //                                ),
                      //                              ),
                      //                            ),
                      //                            Expanded(
                      //                              child: InkWell(
                      //                                onTap: () {
                      //                                  if (productWeight > 1) {
                      //                                    productWeight = productWeight - 1;
                      //                                    print('productCount' +
                      //                                        productWeight.toString());
                      //
                      //                                    Provider.of<Wastes>(context, listen: false)
                      //                                        .updateWasteCart(
                      //                                            widget.wasteItem,
                      //                                            productWeight.toString(),
                      //                                            widget.wasteItem.isAdded);
                      ////                                                        changeNumberAnimation(
                      ////                                                            double.parse(getPrice(
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .prices,
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .weight)) *
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight);
                      //                                  }
                      //                                  widget.function();
                      //                                },
                      //                                onDoubleTap: () async {
                      //                                  if (productWeight > 10) {
                      //                                    productWeight = productWeight - 10;
                      //                                    print('productCount' +
                      //                                        productWeight.toString());
                      //
                      //                                    Provider.of<Wastes>(context, listen: false)
                      //                                        .updateWasteCart(
                      //                                            widget.wasteItem,
                      //                                            productWeight.toString(),
                      //                                            widget.wasteItem.isAdded);
                      ////                                                        changeNumberAnimation(
                      ////                                                            double.parse(getPrice(
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .prices,
                      ////                                                                    widget
                      ////                                                                        .wasteItem
                      ////                                                                        .weight)) *
                      ////                                                                widget.wasteItem
                      ////                                                                    .weight);
                      //                                  }
                      //                                  widget.function();
                      //                                },
                      //                                child: Container(
                      //                                  decoration: BoxDecoration(
                      //                                    shape: BoxShape.circle,
                      //                                    color: AppTheme.accent,
                      //                                  ),
                      //                                  child: Icon(
                      //                                    Icons.remove,
                      //                                    color: AppTheme.bg,
                      //                                  ),
                      //                                ),
                      //                              ),
                      //                            ),
                      //                          ],
                      //                        ),
                      //                      ),
                      SizedBox(width: constraints.maxWidth * 0.01),
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
