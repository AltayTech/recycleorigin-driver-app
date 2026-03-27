import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_state.dart';
import 'package:recycleorigindriver/core/models/request/delivery_waste_item.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/screens/send_delivery_screen.dart';
import 'package:recycleorigindriver/core/widgets/buton_bottom.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/widgets/collect_item_store_collect_screen.dart';
import 'package:recycleorigindriver/core/widgets/custom_dialog_enter.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/widgets/custom_dialog_profile.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';

class StoreCollectListScreen extends StatefulWidget {
  static const routeName = '/StoreCollectListScreen';

  @override
  _StoreCollectListScreenState createState() => _StoreCollectListScreenState();
}

class _StoreCollectListScreenState extends State<StoreCollectListScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;

  ScrollController _scrollController = new ScrollController();

  var _isLoading;

  var scaffoldKey;
  int page = 1;

  SearchDetail? productsDetail;

  @override
  void initState() {
    context.read<DeliveriesBloc>().sPage = 1;

    context.read<DeliveriesBloc>().searchBuilder();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < (productsDetail?.max_page ?? 1)) {
          page = page + 1;
          context.read<DeliveriesBloc>().sPage = page;

          searchItems();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  List<DeliveryWasteItem> loadedProducts = [];
  List<DeliveryWasteItem> loadedProductstolist = [];

  Future<void> _submit() async {
    loadedProducts.clear();
    loadedProducts = List<DeliveryWasteItem>.from(
        context.read<DeliveriesBloc>().state.deliveriesItems);
    loadedProductstolist.addAll(loadedProducts);
  }

  Future<void> filterItems() async {
    loadedProductstolist.clear();
    await searchItems();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      context.read<DeliveriesBloc>().searchBuilder();
      await context.read<DeliveriesBloc>().searchCollectItems();
      productsDetail = context.read<DeliveriesBloc>().state.searchDetails;
      if (productsDetail == null) {
        loadedProductstolist.clear();
      }
      _submit();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    print(_isLoading.toString());

    context.read<DeliveriesBloc>().sPage = 1;

    context.read<DeliveriesBloc>().searchBuilder();

    loadedProductstolist.clear();

    await searchItems();

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
  }

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

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = context.watch<AuthBloc>().state.isAuth;
    bool isCompleted = context.watch<AuthBloc>().state.isCompleted;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: !isLogin
              ? Container(
                  height: deviceHeight * 0.55,
                  width: deviceWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(context.l10n.notLoggedInLabel),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              context.l10n.loginToAccountLabel,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: deviceHeight * 0.0,
                      horizontal: deviceWidth * 0.00),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: deviceHeight * 0.63,
                        width: deviceWidth,
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.08),
                                      blurRadius: 10.10,
                                      spreadRadius: 10,
                                      offset: Offset(
                                        0, // horizontal, move right 10

                                        0, // vertical, move down 10
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const Spacer(),
                                        Expanded(
                                          child: BlocBuilder<DeliveriesBloc,
                                              DeliveriesState>(
                                            buildWhen: (p, c) =>
                                                p.searchDetails !=
                                                    c.searchDetails ||
                                                p.deliveriesItems !=
                                                    c.deliveriesItems,
                                            builder: (context, deliveryState) {
                                              return Container(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          deviceHeight * 0.0,
                                                      horizontal: 3),
                                                  child: Wrap(
                                                      alignment:
                                                          WrapAlignment.start,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      direction:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 5),
                                                          child: Text(
                                                            context.l10n
                                                                .countWithColon,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Iransans',
                                                              fontSize:
                                                                  textScaleFactor *
                                                                      12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4.0,
                                                                  left: 6),
                                                          child: Text(
                                                            productsDetail !=
                                                                    null
                                                                ? EnArConvertor()
                                                                    .replaceArNumber(
                                                                        loadedProductstolist
                                                                            .length
                                                                            .toString())
                                                                : EnArConvertor()
                                                                    .replaceArNumber(
                                                                        '0'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Iransans',
                                                              fontSize:
                                                                  textScaleFactor *
                                                                      13.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 5),
                                                          child: Text(
                                                            context
                                                                .l10n.ofLabel,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Iransans',
                                                              fontSize:
                                                                  textScaleFactor *
                                                                      12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4.0,
                                                                  left: 6),
                                                          child: Text(
                                                            productsDetail !=
                                                                    null
                                                                ? EnArConvertor()
                                                                    .replaceArNumber(
                                                                        (productsDetail?.total ??
                                                                                0)
                                                                            .toString())
                                                                : EnArConvertor()
                                                                    .replaceArNumber(
                                                                        '0'),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Iransans',
                                                              fontSize:
                                                                  textScaleFactor *
                                                                      13.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: deviceHeight * 0.450,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.vertical,
                                        itemCount: loadedProductstolist.length,
                                        itemBuilder: (ctx, i) =>
                                            ChangeNotifierProvider.value(
                                          value: loadedProductstolist[i],
                                          child:
                                              CollectItemStoreCollectsScreen(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () async {
                            SnackBar addToCartSnackBar = SnackBar(
                              content: Text(
                                context.l10n.alreadyCollected,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Iransans',
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
                            if (loadedProducts.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(addToCartSnackBar);
                            } else if (!isLogin) {
                              _showLogindialog();
                            } else {
                              Navigator.of(context)
                                  .pushNamed(SendDeliveryScreen.routeName);
                            }
                          },
                          child: ButtonBottom(
                            width: deviceWidth * 0.9,
                            height: deviceWidth * 0.14,
                            text: context.l10n.deliverToWarehouseLabel,
                            isActive: loadedProducts.isNotEmpty,
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
                              : Container(
                                  child: loadedProductstolist.isEmpty
                                      ? Center(
                                          child: Text(
                                            context.l10n.noProductAvailable,
                                            style: TextStyle(
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 15.0,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
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
