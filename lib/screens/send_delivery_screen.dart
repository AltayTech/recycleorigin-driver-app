import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/models/request/collect.dart';
import 'package:recycleorigindriver/models/request/request_waste.dart';
import 'package:recycleorigindriver/provider/customer_info.dart';
import 'package:recycleorigindriver/provider/deliveries.dart';
import 'package:recycleorigindriver/widgets/collect_delivery_detail_item.dart';
import 'package:recycleorigindriver/widgets/custom_dialog_send_delivery.dart';
import 'package:recycleorigindriver/widgets/custom_dialog_send_request.dart';
import 'package:recycleorigindriver/widgets/header_total.dart';

import '../provider/app_theme.dart';
import '../provider/auth.dart';
import '../widgets/buton_bottom.dart';
import '../widgets/custom_dialog_enter.dart';
import '../widgets/custom_dialog_profile.dart';
import '../widgets/main_drawer.dart';
import 'navigation_bottom_screen.dart';

class SendDeliveryScreen extends StatefulWidget {
  static const routeName = '/SendDeliveryScreen';

  @override
  _SendDeliveryScreenState createState() => _SendDeliveryScreenState();
}

class _SendDeliveryScreenState extends State<SendDeliveryScreen>
    with TickerProviderStateMixin {
//  List<WasteCart> wasteCartItems = [];
  bool _isInit = true;

  var _isLoading = true;
  double totalPrice = 0;
  double totalWeight = 0.0;
  List<Collect> loadedCollect = [];

  late RequestWaste requestWaste;

  void _showLogindialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogEnter(
        title: 'ورود',
        buttonText: 'صفحه ورود ',
        description: 'برای ادامه باید وارد شوید',
        image: Image.asset(''),

      ),
    );
  }

  void _showCompletedialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogProfile(
        title: 'اطلاعات کاربری',
        buttonText: 'صفحه پروفایل ',
        description: 'برای ادامه باید اطلاعات کاربری تکمیل کنید',
        image: Image.asset(''),

      ),
    );
  }

  void _showSenddialog() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialogSendRequest(
        title: '',
        buttonText: 'خب',
        description: 'درخواست شما با موفقیت ثبت شد',
        image: Image.asset(''),

      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Provider.of<Auth>(context, listen: false).checkCompleted();
      await searchItems();

      await getWasteItems();
      await Provider.of<CustomerInfo>(context, listen: false).getCustomer();
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

    await Provider.of<Deliveries>(context, listen: false)
        .getCollectedItemsToDeliver();
    loadedCollect =
        Provider.of<Deliveries>(context, listen: false).toDeliveryCollectItems;
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
    loadedCollect =
        Provider.of<Deliveries>(context, listen: false).toDeliveryCollectItems;
//    wasteCartItems = Provider.of<Deliveries>(context, listen: false).wasteCartItems;
    totalPrice = 0;
    totalWeight = 0;
    if (loadedCollect.length > 0) {
      for (int i = 0; i < loadedCollect.length; i++) {
        totalPrice =
            totalPrice + double.parse(loadedCollect[i].estimated_price);

        totalWeight =
            totalWeight + double.parse(loadedCollect[i].estimated_weight);
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
    bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;
    await Provider.of<Deliveries>(context, listen: false)
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
    var currencyFormat = intl.NumberFormat.decimalPattern();
    bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          'جزئیات درخواست',
          style: TextStyle(
            color: AppTheme.white,
            fontFamily: 'Iransans',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Builder(builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        HeaderTotal(
                          totalNumber: loadedCollect.length,
                          totalPrice: totalPrice,
                          totalWeight: totalWeight,
                          totalPriceController: _totalPriceController,
                          totalPriceAnimation: _totalPriceAnimation,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Consumer<Deliveries>(
                            builder: (_, value, ch) => value
                                        .toDeliveryCollectItems.length !=
                                    0
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  'نوع',
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'وزن(کیلوگرم) ',
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'قیمت(تومان)',
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
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
                                            itemCount: value
                                                .toDeliveryCollectItems.length,
                                            itemBuilder: (ctx, i) =>
                                                CollectDeliveryDetailItem(
                                              wasteItem: value
                                                  .toDeliveryCollectItems[i],
                                              function: getWasteItems,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    height: deviceHeight * 0.5,
                                    child: Center(
                                      child:
                                          Text('پسماندی برای تحویل وجود ندارد'),
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
                                  color:
                                      index.isEven ? Colors.grey : Colors.grey,
                                ),
                              );
                            },
                          )
                        : InkWell(
                            onTap: () async {
                              SnackBar addToCartSnackBar = SnackBar(
                                content: Text(
                                  'قبلا جمع آوری شده است!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Iransans',
                                    fontSize: textScaleFactor * 14.0,
                                  ),
                                ),
                                action: SnackBarAction(
                                  label: 'متوجه شدم',
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
                              text: 'تحویل',
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
