import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/widgets/statistic_item_statistics_screen.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/wastes_bloc.dart';
import '../l10n/l10n.dart';
import '../models/request/request_waste_item.dart';
import '../models/search_detail.dart';
import '../provider/app_theme.dart';
import '../widgets/main_drawer.dart';
import 'customer_info/login_screen.dart';

class StatisticsListScreen extends StatefulWidget {
  static const routeName = '/StatisticsListScreen';

  @override
  _StatisticsListScreenState createState() => _StatisticsListScreenState();
}

class _StatisticsListScreenState extends State<StatisticsListScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;

  ScrollController _scrollController = new ScrollController();

  var _isLoading;

  var scaffoldKey;
  int page = 1;

  SearchDetail? productsDetail;

  @override
  void initState() {
    context.read<WastesBloc>().sPage = 1;

    context.read<WastesBloc>().searchBuilder();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final maxPage = productsDetail?.max_page ?? 1;
        if (page < maxPage) {
          page = page + 1;
          context.read<WastesBloc>().sPage = page;

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

  List<RequestWasteItem> loadedProducts = [];
  List<RequestWasteItem> loadedProductstolist = [];

  Future<void> _submit() async {
    loadedProducts.clear();
    loadedProducts =
        List<RequestWasteItem>.from(context.read<WastesBloc>().state.collectItems);
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

    context.read<WastesBloc>().searchBuilder();
    await context.read<WastesBloc>().searchCollectItems();
    productsDetail = context.read<WastesBloc>().state.searchDetails;
    _submit();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> changeCat(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    print(_isLoading.toString());

    context.read<WastesBloc>().sPage = 1;

    context.read<WastesBloc>().searchBuilder();

    loadedProductstolist.clear();

    await searchItems();

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = context.watch<AuthBloc>().state.isAuth;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: !isLogin
              ? Container(
                  height: deviceHeight * 0.4,
                  width: deviceWidth,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.08),
                          blurRadius: 10.10,
                          spreadRadius: 10.510,
                          offset: Offset(
                            0,
                            0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(10)),
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
                      horizontal: deviceWidth * 0.03),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: AppTheme.white,
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
                                  Container(
                                    width: double.infinity,
                                    height: deviceHeight * 0.68,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      scrollDirection: Axis.vertical,
                                      itemCount: loadedProductstolist.length,
                                      itemBuilder: (ctx, i) =>
                                          ChangeNotifierProvider.value(
                                        value: loadedProductstolist[i],
                                        child: StatisticItemStatisticsScreen(
                                          headColor: Colors.blue,
                                          title: context.l10n.todayLabel,
                                          price: '65000',
                                          weight: '10',
                                          number: '6',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
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
