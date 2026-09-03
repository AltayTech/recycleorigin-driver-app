import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/core/models/clearing.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/widgets/clearing_item_clear_screen.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/models/customer.dart';
import 'package:recycleorigindriver/core/models/search_detail.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_state.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/core/widgets/buton_bottom.dart';
import 'package:recycleorigindriver/core/widgets/currency_input_formatter.dart';
import 'package:recycleorigindriver/core/widgets/custom_dialog_send_request.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';

class ClearScreen extends StatefulWidget {
  static const routeName = '/ClearScreen';

  const ClearScreen({super.key});

  @override
  State<ClearScreen> createState() => _ClearScreenState();
}

class _ClearScreenState extends State<ClearScreen>
    with SingleTickerProviderStateMixin {
  bool _isInit = true;
  var _isLoading = false;
  int page = 1;
  SearchDetail? productsDetail;
  final ScrollController _scrollController = ScrollController();

  late Customer customer;

  final shabaController = TextEditingController();
  final donationController = TextEditingController();

  @override
  void initState() {
    context.read<ClearingsBloc>().sPage = 1;

    context.read<ClearingsBloc>().searchBuilder();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (page < (productsDetail?.max_page ?? 1)) {
          page = page + 1;
          context.read<ClearingsBloc>().sPage = page;

          searchItems();
        }
      }
    });

    shabaController.text = 'IR';
    donationController.text = '0';
    super.initState();
  }

  @override
  void dispose() {
    shabaController.dispose();
    donationController.dispose();
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
    bool isLogin = context.read<AuthBloc>().state.isAuth;
    if (isLogin) {
      await context.read<CustomerInfoBloc>().getCustomer();
    }
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

  List<Clearing> loadedProducts = [];
  List<Clearing> loadedProductstolist = [];

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });

    context.read<ClearingsBloc>().searchBuilder();
    await context.read<ClearingsBloc>().searchCleaingsItems();
    if (!mounted) {
      return;
    }
    productsDetail = context.read<ClearingsBloc>().state.searchDetails;

    loadedProducts.clear();
    loadedProducts = List<Clearing>.from(
      context.read<ClearingsBloc>().state.deliveriesItems,
    );
    loadedProductstolist.addAll(loadedProducts);

    setState(() {
      _isLoading = false;
    });
  }

  String removeSemicolon(String rawString) {
    return rawString.replaceAll(',', '');
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    bool isLogin = context.watch<AuthBloc>().state.isAuth;

    final currencyFormat = EnArConvertor.decimalPatternFor(context);

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(context.l10n.settlementRequestTitle),
        elevation: 0,
        centerTitle: true,
        actions: const <Widget>[],
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: deviceHeight * 0.0,
                horizontal: deviceWidth * 0.03,
              ),
              child: !isLogin
                  ? SizedBox(
                      height: deviceHeight * 0.8,
                      child: Center(
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(context.l10n.notLoggedInLabel),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(LoginScreen.routeName);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.brandPrimary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    context.l10n.loginToAccountLabel,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: context.pageBackground,
                      height: deviceHeight * 0.9,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 4,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.brandPrimary
                                              .withValues(alpha: 0.08),
                                          blurRadius: 10.10,
                                          spreadRadius: 10.510,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            context.l10n.pointsLabel,
                                            style: TextStyle(
                                              color: context.secondaryText,
                                              fontSize: textScaleFactor * 13.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                BlocBuilder<
                                                  CustomerInfoBloc,
                                                  CustomerInfoState
                                                >(
                                                  buildWhen: (p, c) =>
                                                      p.driver.money !=
                                                      c.driver.money,
                                                  builder: (_, data) => Text(
                                                    EnArConvertor.localize(
                                                      context,
                                                      currencyFormat.format(
                                                        double.parse(
                                                          data.driver.money,
                                                        ).roundToDouble(),
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      color:
                                                          context.primaryText,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          textScaleFactor *
                                                          18.0,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                          ),
                                          Text(
                                            context.l10n.tomanLabel,
                                            style: TextStyle(
                                              color: context.secondaryText,
                                              fontSize: textScaleFactor * 13.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    context.l10n.shebaNumberLabel,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: context.primaryText,
                                    fontSize: textScaleFactor * 16.0,
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  textInputAction: TextInputAction.go,
                                  keyboardType: TextInputType.number,
                                  controller: shabaController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      gapPadding: 10,
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: scheme.surface,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontSize: textScaleFactor * 10.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    context.l10n.requestedAmountToman,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 14.0,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextFormField(
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontSize: textScaleFactor * 16.0,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.go,
                                    controller: donationController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20,
                                        top: 0,
                                        bottom: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          width: 0,
                                          color: scheme.surface,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontSize: textScaleFactor * 10.0,
                                      ),
                                    ),
                                    inputFormatters: [
                                      // WhitelistingTextInputFormatter
                                      //     .digitsOnly,
                                      CurrencyInputFormatter(),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    context.l10n.payoutStaffHandledHint,
                                    style: TextStyle(
                                      color: context.secondaryText,
                                      fontSize: textScaleFactor * 12.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: context.pageBackground,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            right: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                context.l10n.requestListTitle,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: context.primaryText
                                                      .withValues(alpha: 0.5),
                                                  fontSize:
                                                      textScaleFactor * 14.0,
                                                ),
                                              ),
                                              Spacer(),
                                              BlocBuilder<
                                                ClearingsBloc,
                                                ClearingsState
                                              >(
                                                buildWhen: (p, c) =>
                                                    p.searchDetails !=
                                                        c.searchDetails ||
                                                    p.deliveriesItems !=
                                                        c.deliveriesItems,
                                                builder: (_, clearingState) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical:
                                                              deviceHeight *
                                                              0.0,
                                                          horizontal: 3,
                                                        ),
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
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 3,
                                                                vertical: 5,
                                                              ),
                                                          child: Text(
                                                            context
                                                                .l10n
                                                                .countWithColon,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  textScaleFactor *
                                                                  12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                right: 4.0,
                                                                left: 6,
                                                              ),
                                                          child: Text(
                                                            EnArConvertor.localize(
                                                              context,
                                                              productsDetail !=
                                                                      null
                                                                  ? loadedProductstolist
                                                                        .length
                                                                        .toString()
                                                                  : '0',
                                                            ),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  textScaleFactor *
                                                                  13.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 3,
                                                                vertical: 5,
                                                              ),
                                                          child: Text(
                                                            context
                                                                .l10n
                                                                .ofLabel,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  textScaleFactor *
                                                                  12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                right: 4.0,
                                                                left: 6,
                                                              ),
                                                          child: Text(
                                                            EnArConvertor.localize(
                                                              context,
                                                              productsDetail !=
                                                                      null
                                                                  ? (productsDetail?.total ??
                                                                            0)
                                                                        .toString()
                                                                  : '0',
                                                            ),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  textScaleFactor *
                                                                  13.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: deviceWidth * 0.08,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: Text(
                                                    context.l10n.statusLabel,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          context.secondaryText,
                                                      fontSize:
                                                          textScaleFactor *
                                                          12.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: Text(
                                                    context
                                                        .l10n
                                                        .amountTomanLabel,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          context.secondaryText,
                                                      fontSize:
                                                          textScaleFactor *
                                                          12.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: scheme.outlineVariant,
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          height: deviceHeight * 0.42,
                                          child: ListView.builder(
                                            controller: _scrollController,
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                loadedProductstolist.length,
                                            itemBuilder: (ctx, i) =>
                                                ChangeNotifierProvider.value(
                                                  value:
                                                      loadedProductstolist[i],
                                                  child:
                                                      ClearingItemClearScreen(),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 15,
                            right: 15,
                            child: InkWell(
                              onTap: () async {
                                SnackBar addToCartSnackBar = SnackBar(
                                  content: Text(
                                    context.l10n.enterShebaNumber,
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
                                if (shabaController.text == 'IR') {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(addToCartSnackBar);
                                } else {
                                  await context
                                      .read<CustomerInfoBloc>()
                                      .sendClearingRequest(
                                        removeSemicolon(
                                          donationController.text,
                                        ),
                                        shabaController.text,
                                        isLogin,
                                      );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    NavigationBottomScreen.routeName,
                                    (Route<dynamic> route) => false,
                                  );
                                  _showSenddialog();
                                }
                              },
                              child: ButtonBottom(
                                width: deviceWidth * 0.9,
                                height: deviceWidth * 0.14,
                                text: context.l10n.submitRequestLabel,
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
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
