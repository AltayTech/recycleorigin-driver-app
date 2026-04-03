import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_state.dart';
import 'package:recycleorigindriver/core/models/request/collect.dart';
import 'package:recycleorigindriver/core/models/request/request_waste.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/widgets/collect_delivery_detail_item.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/widgets/custom_dialog_send_delivery.dart';
import 'package:recycleorigindriver/core/widgets/custom_dialog_send_request.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/buton_bottom.dart';
import 'package:recycleorigindriver/core/widgets/custom_dialog_enter.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/widgets/custom_dialog_profile.dart';

class DeliveryDetailScreen extends StatefulWidget {
  static const routeName = '/DeliveryDetailScreen';

  @override
  _DeliveryDetailScreenState createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen>
    with TickerProviderStateMixin {
//  List<WasteCart> wasteCartItems = [];
  bool _isInit = true;

  var _isLoading = true;
  int totalPrice = 0;
  int totalWeight = 0;
  int totalPricePure = 0;
  List<Collect> loadedCollect = [];

  late RequestWaste requestWaste;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: context.l10n.loginLabel,
        buttonText: context.l10n.loginPageLabel,
        description: context.l10n.loginRequiredDescription,
        image: Image.asset(''),
      ),
    );
  }

  void _showCompletedialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogProfile(
        title: context.l10n.personalInfoLabel,
        buttonText: context.l10n.profilePageLabel,
        description: context.l10n.completeProfileDescription,
        image: Image.asset(''),
      ),
    );
  }

  void _showSenddialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogSendRequest(
        title: '',
        buttonText: context.l10n.okLabel,
        description: context.l10n.requestSubmittedSuccess,
        image: Image.asset(''),
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await context.read<AuthBloc>().checkCompleted();
      await searchItems();

      await getWasteItems();
      await context.read<CustomerInfoBloc>().getCustomer();
      print(
          'didChangeDependenciesdidChangeDependenciesdidChangeDependenciesdidChangeDependencies');

      setState(() {});
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
//    final productId = ModalRoute.of(context).settings.arguments as int;
//    await Provider.of<Wastes>(context, listen: false)
//        .retrieveCollectItem(productId);

    await context.read<DeliveriesBloc>().getCollectedItemsToDeliver();
    loadedCollect = context.read<DeliveriesBloc>().state.toDeliveryCollectItems;
//    await Provider.of<Deliveries>(context, listen: false)
//        .addInitialWasteCart(loadedCollect.collect_list, true);
//    loadedCollect =
//        Provider.of<Deliveries>(context, listen: false).requestWasteItem;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getWasteItems() async {
    setState(() {
      _isLoading = true;
    });
    loadedCollect = context.read<DeliveriesBloc>().state.toDeliveryCollectItems;
//    wasteCartItems = Provider.of<Deliveries>(context, listen: false).wasteCartItems;
    totalPrice = 0;
    totalWeight = 0;
    if (loadedCollect.length > 0) {
      for (int i = 0; i < loadedCollect.length; i++) {
        totalPrice = totalPrice + int.parse(loadedCollect[i].estimated_price);

        totalWeight =
            totalWeight + int.parse(loadedCollect[i].estimated_weight);
      }
    }
    changeNumberAnimation(double.parse(totalPrice.toString()));

    setState(() {
      _isLoading = false;
    });
  }

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

  late AnimationController _totalPriceController;
  late Animation<double> _totalPriceAnimation;

  @override
  initState() {
    _totalPriceController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _totalPriceAnimation = _totalPriceController;
    super.initState();
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    super.dispose();
  }

  void changeNumberAnimation(double newValue) {
    setState(() {
      _totalPriceAnimation = new Tween<double>(
        begin: _totalPriceAnimation.value,
        end: newValue,
      ).animate(new CurvedAnimation(
        curve: Curves.ease,
        parent: _totalPriceController,
      ));
    });
    _totalPriceController.forward(from: 0.0);
  }

//  Future<void> createRequest(BuildContext context, bool collected) async {
//    setState(() {
//      _isLoading = true;
//    });
//
//    List<Collect> collectList = [];
//    for (int i = 0; i < wasteCartItems.length; i++) {
//      if (wasteCartItems[i].isAdded) {
//        collectList.add(
//          Collect(
//            estimated_weight: wasteCartItems[i].estimated_weight,
//            estimated_price: wasteCartItems[i].estimated_price,
//            exact_weight: wasteCartItems[i].exact_weight,
//            exact_price: wasteCartItems[i].exact_price,
//            pasmand: Pasmand(
//                id: wasteCartItems[i].pasmand.id,
//                post_title: wasteCartItems[i].pasmand.post_title),
//          ),
//        );
//      } else if (!wasteCartItems[i].isAdded) {
//        collectList.add(
//          Collect(
//            estimated_weight: wasteCartItems[i].estimated_weight,
//            estimated_price: wasteCartItems[i].estimated_price,
//            exact_weight: '0',
//            exact_price: '0',
//            pasmand: Pasmand(
//                id: wasteCartItems[i].pasmand.id,
//                post_title: wasteCartItems[i].pasmand.post_title),
//          ),
//        );
//      }
//    }
//
//    requestWaste = RequestWaste(
//      collect_list: collectList,
//      collected: collected,
//    );
//
//    setState(() {
//      _isLoading = false;
//    });
//  }
//
  Future<void> sendRequest(
    int storeId,
  ) async {
    setState(() {
      _isLoading = true;
    });
    bool isLogin = context.read<AuthBloc>().state.isAuth;
    await context
        .read<DeliveriesBloc>()
        .sendRequest(
          storeId,
          isLogin,
        )
        .then((value) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          NavigationBottomScreen.routeName, (Route<dynamic> route) => false);
      _showSenddialog();
    });
    print(
        'didChangeDependenciesdidChangeDependenciesdidChangeDependenciesdidChangeDependencies');

    setState(() {
      _isLoading = false;
    });
  }

  void _showSendDeliveryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogSendDelivery(
        totalWallet: 1000,
        function: (int storeId) {
          sendRequest(storeId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final currencyFormat = EnArConvertor.decimalPatternFor(context);
    bool isLogin = context.read<AuthBloc>().state.isAuth;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.requestDetailTitle,
          style: TextStyle(
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: deviceHeight * 0.15,
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
                                    Expanded(
                                      child: Icon(
                                        Icons.restore_from_trash,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                    Text(
                                      EnArConvertor.localize(
                                        context,
                                        loadedCollect.length.toString(),
                                      ),
                                      style: TextStyle(
                                        color: AppTheme.h1,
                                        fontSize: textScaleFactor * 18,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.countLabel,
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: textScaleFactor * 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Icon(
                                        Icons.monetization_on,
                                        color: AppTheme.primary,
                                        size: 40,
                                      ),
                                    ),
                                    AnimatedBuilder(
                                      animation: _totalPriceAnimation,
                                      builder: (context, child) {
                                        return new Text(
                                          totalPrice.toString().isNotEmpty
                                              ? EnArConvertor.localize(
                                                  context,
                                                  currencyFormat.format(
                                                    double.parse(
                                                      _totalPriceAnimation.value
                                                          .toStringAsFixed(0),
                                                    ),
                                                  ),
                                                )
                                              : EnArConvertor.localize(
                                                  context,
                                                  '0',
                                                ),
                                          style: TextStyle(
                                            color: AppTheme.h1,
                                            fontSize: textScaleFactor * 18,
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Icon(
                                        Icons.av_timer,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                    ),
                                    Text(
                                      EnArConvertor.localize(
                                        context,
                                        totalWeight.toString(),
                                      ),
                                      style: TextStyle(
                                        color: AppTheme.h1,
                                        fontSize: textScaleFactor * 18,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.kilogramLabel,
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: textScaleFactor * 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: BlocBuilder<DeliveriesBloc, DeliveriesState>(
                          buildWhen: (p, c) =>
                              p.toDeliveryCollectItems !=
                              c.toDeliveryCollectItems,
                          builder: (_, deliveryState) =>
                              deliveryState.toDeliveryCollectItems.length != 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    context.l10n.typeLabel,
                                                    style: TextStyle(
                                                      color: AppTheme.grey,
                                                      fontSize:
                                                          textScaleFactor * 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    context.l10n.weightKgLabel,
                                                    style: TextStyle(
                                                      color: AppTheme.grey,
                                                      fontSize:
                                                          textScaleFactor * 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    context
                                                        .l10n.priceTomanLabel,
                                                    style: TextStyle(
                                                      color: AppTheme.grey,
                                                      fontSize:
                                                          textScaleFactor * 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: deviceHeight * 0.6,
                                            decoration: BoxDecoration(
                                              color: AppTheme.white,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: ListView.builder(
//                                        shrinkWrap: true,
//                                        physics:
//                                            const NeverScrollableScrollPhysics(),
                                              itemCount: deliveryState
                                                  .toDeliveryCollectItems
                                                  .length,
                                              itemBuilder: (ctx, i) =>
                                                  CollectDeliveryDetailItem(
                                                wasteItem: deliveryState
                                                    .toDeliveryCollectItems[i],
                                                function: getWasteItems,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: deviceHeight * 0.7,
                                      child: Center(
                                        child: Text(context.l10n.noWasteAdded),
                                      ),
                                    ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
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
                      : InkWell(
                          onTap: () async {
                            SnackBar addToCartSnackBar = SnackBar(
                              content: Text(
                                context.l10n.alreadyCollected,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textScaleFactor * 14.0,
                                ),
                              ),
                              action: SnackBarAction(
                                label: context.l10n.gotItLabel,
                                onPressed: () {
                                  // Some code to undo the change.
                                },
                              ),
                            );
                            if (loadedCollect.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(addToCartSnackBar);
                            } else if (!isLogin) {
                              _showLogindialog();
                            } else {
                              _showSendDeliveryDialog();
//                                await createRequest(context, true).then(
//                                  (value) =>
//                                      sendRequest(context, isLogin).then(
//                                    (value) {
//                                      Navigator.of(context)
//                                          .pushNamedAndRemoveUntil(
//                                              NavigationBottomScreen
//                                                  .routeName,
//                                              (Route<dynamic> route) =>
//                                                  false);
//                                    },
//                                  ),
//                                );
//                                _showSenddialog();
                            }
                          },
                          child: ButtonBottom(
                            width: deviceWidth * 0.9,
                            height: deviceWidth * 0.14,
                            text: context.l10n.confirmLabel,
                            isActive: loadedCollect.isNotEmpty,
                          ),
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
                                  color:
                                      index.isEven ? Colors.grey : Colors.grey,
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
        );
      }),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ),
    );
  }
}
