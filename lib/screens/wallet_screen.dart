import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:tamizshahrdriver/widgets/buton_bottom.dart';

import '../models/customer.dart';
import '../models/search_detail.dart';
import '../models/transaction.dart';
import '../provider/app_theme.dart';
import '../provider/auth.dart';
import '../provider/customer_info.dart';
import '../screens/clear_screen.dart';
import '../widgets/en_to_ar_number_convertor.dart';
import '../widgets/main_drawer.dart';
import '../widgets/transaction_item_transactions_screen.dart';
import 'customer_info/login_screen.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/walletScreen';

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;
  ScrollController _scrollController = new ScrollController();
  var _isLoading;
  int page = 1;
  late SearchDetail productsDetail;

  late Customer customer;

  @override
  void initState() {
    Provider.of<CustomerInfo>(context, listen: false).sPage = 1;

    Provider.of<CustomerInfo>(context, listen: false).searchBuilder();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < productsDetail.max_page) {
          page = page + 1;
          Provider.of<CustomerInfo>(context, listen: false).sPage = page;

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
      getCustomerInfo();
      searchItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getCustomerInfo() async {
    bool isLogin = Provider.of<Auth>(context, listen: false).isAuth;
    if (isLogin) {
      await Provider.of<CustomerInfo>(context, listen: false).getCustomer();
    }
  }

  List<Transaction> loadedProducts = [];
  List<Transaction> loadedProductstolist = [];

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    Provider.of<CustomerInfo>(context, listen: false).searchBuilder();
    await Provider.of<CustomerInfo>(context, listen: false)
        .searchTransactionItems();
    productsDetail =
        Provider.of<CustomerInfo>(context, listen: false).searchDetails;

    loadedProducts.clear();
    loadedProducts = await Provider.of<CustomerInfo>(context, listen: false)
        .transactionItems;
    loadedProductstolist.addAll(loadedProducts);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isLogin = Provider.of<Auth>(context).isAuth;

    var currencyFormat = intl.NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'کیف پول',
          style: TextStyle(
            fontFamily: 'Iransans',
          ),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: deviceHeight * 0.0, horizontal: deviceWidth * 0.03),
            child: !isLogin
                ? Container(
                    height: deviceHeight * 0.8,
                    child: Center(
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('شما وارد نشده اید'),
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
                                  'ورود به حساب کاربری',
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
                    ),
                  )
                : Container(
                    height: deviceHeight * 0.89,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  border:
                                      Border.all(width: 5, color: AppTheme.bg)),
                              height: deviceWidth * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      height: deviceWidth * 0.9,
                                      width: deviceWidth,
                                      child: FadeInImage(
                                        placeholder: AssetImage(
                                            'assets/images/circle.gif'),
                                        image: AssetImage(
                                            'assets/images/wallet_money_bg.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'امتیاز',
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 13.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Consumer<CustomerInfo>(
                                            builder: (_, data, ch) => Text(
                                              data.driver != null
                                                  ? EnArConvertor()
                                                      .replaceArNumber(
                                                          currencyFormat
                                                              .format(double
                                                                  .parse(data
                                                                      .driver
                                                                      .money))
                                                              .toString())
                                                  : EnArConvertor()
                                                      .replaceArNumber(
                                                          currencyFormat.format(
                                                              double.parse(
                                                                  '0'))),
                                              style: TextStyle(
                                                color: AppTheme.black,
                                                fontFamily: 'Iransans',
                                                fontWeight: FontWeight.w700,
                                                fontSize:
                                                    textScaleFactor * 18.0,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Text(
                                            'تومان',
                                            style: TextStyle(
                                              color: AppTheme.grey,
                                              fontFamily: 'Iransans',
                                              fontSize: textScaleFactor * 13.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppTheme.bg,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, right: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'لیست تراکنش ها',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.black
                                                    .withOpacity(0.8),
                                                fontFamily: 'Iransans',
                                                fontSize:
                                                    textScaleFactor * 14.0,
                                              ),
                                            ),
                                            Spacer(),
                                            Consumer<CustomerInfo>(
                                                builder: (_, Wastes, ch) {
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
                                                    direction: Axis.horizontal,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 3,
                                                                vertical: 5),
                                                        child: Text(
                                                          'تعداد:',
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
                                                          productsDetail != null
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
                                                          'از',
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
                                                          productsDetail != null
                                                              ? EnArConvertor()
                                                                  .replaceArNumber(
                                                                      productsDetail
                                                                          .total
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
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: deviceWidth * 0.10,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'نوع',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 15.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'برای',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 15.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'مبلغ (تومان)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 15.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: deviceHeight * 0.42,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          scrollDirection: Axis.vertical,
                                          itemCount:
                                              loadedProductstolist.length,
                                          itemBuilder: (ctx, i) =>
                                              ChangeNotifierProvider.value(
                                            value: loadedProductstolist[i],
                                            child:
                                                TransactionItemTransactionsScreen(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 15,
                          left: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(ClearScreen.routeName);
                            },
                            child: ButtonBottom(
                              width: deviceWidth * 0.9,
                              height: deviceWidth * 0.14,
                              text: 'درخواست تسویه حساب',
                              isActive: true,
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
                                                'تراکنشی وجود ندارد',
                                                style: TextStyle(
                                                  fontFamily: 'Iransans',
                                                  fontSize:
                                                      textScaleFactor * 15.0,
                                                ),
                                              ))
                                            : Container())))
                      ],
                    ),
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
