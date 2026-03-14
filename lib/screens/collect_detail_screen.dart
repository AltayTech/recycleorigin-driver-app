import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/models/request/wasteCart.dart';
import 'package:recycleorigindriver/widgets/collect_detail_item.dart';
import 'package:recycleorigindriver/widgets/header_total.dart';

import '../l10n/l10n.dart';
import '../provider/app_theme.dart';
import '../provider/auth.dart';
import '../provider/wastes.dart';
import '../widgets/main_drawer.dart';

class CollectDetailScreen extends StatefulWidget {
  static const routeName = '/CollectDetailScreen';

  @override
  _CollectDetailScreenState createState() => _CollectDetailScreenState();
}

class _CollectDetailScreenState extends State<CollectDetailScreen>
    with TickerProviderStateMixin {
  List<WasteCart> wasteCartItems = [];
  bool _isInit = true;

  bool _isLoading = true;
  String? _loadError;
  double totalPrice = 0;
  double totalWeight = 0;
  RequestWasteItem? _loadedCollect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Provider.of<Wastes>(context, listen: false).wasteCartItems = [];
      Provider.of<Auth>(context, listen: false).checkCompleted().then((_) {
        _loadRequest();
      });
    }
  }

  Future<void> _loadRequest() async {
    final collectId = ModalRoute.of(context)?.settings.arguments;
    if (collectId == null || collectId is! int) {
      if (mounted) {
        setState(() {
          _loadError = 'Invalid request';
          _isLoading = false;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      await Provider.of<Wastes>(context, listen: false)
          .retrieveCollectItem(collectId);
      if (!mounted) return;
      final collect =
          Provider.of<Wastes>(context, listen: false).requestWasteItem;
      await Provider.of<Wastes>(context, listen: false).addInitialWasteCart(
        collect.collect_list,
        true,
        collect.status.slug == 'collected',
      );
      if (!mounted) return;
      await getWasteItems();
      if (!mounted) return;
      setState(() {
        _loadedCollect = collect;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> searchItems() async {
    await _loadRequest();
  }

  Future<void> getWasteItems() async {
    setState(() {
      _isLoading = true;
    });
    wasteCartItems = Provider.of<Wastes>(context, listen: false).wasteCartItems;
    totalPrice = 0;
    totalWeight = 0;
    if (wasteCartItems.length > 0) {
      for (int i = 0; i < wasteCartItems.length; i++) {
        totalPrice =
            totalPrice + double.parse(wasteCartItems[i].estimated_price);

        totalWeight =
            totalWeight + double.parse(wasteCartItems[i].exact_weight);
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

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.requestDetailTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontFamily: 'Iransans',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: _buildBody(
        context: context,
        deviceHeight: deviceHeight,
        deviceWidth: deviceWidth,
        textScaleFactor: textScaleFactor,
        theme: theme,
      ),
      endDrawer: Theme(
        data: theme.copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required double deviceHeight,
    required double deviceWidth,
    required double textScaleFactor,
    required ThemeData theme,
  }) {
    if (_loadError != null) {
      return _buildErrorState(context, theme);
    }
    if (_loadedCollect == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    final collect = _loadedCollect!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildAddressAndDateCard(
                    context: context,
                    collect: collect,
                    textScaleFactor: textScaleFactor,
                  ),
                  HeaderTotal(
                          totalNumber: wasteCartItems.length,
                          totalPrice: totalPrice,
                          totalWeight: totalWeight,
                          totalPriceController: _totalPriceController,
                          totalPriceAnimation: _totalPriceAnimation,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Consumer<Wastes>(
                            builder: (_, value, ch) => value
                                        .wasteCartItems.length !=
                                    0
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
                                                  context.l10n.statusLabel,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  context.l10n.typeLabel,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  context.l10n.customerWeightLabel,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  context.l10n.deliveryWeightLabel,
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontFamily: 'Iransans',
                                                    fontSize:
                                                        textScaleFactor * 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: deviceHeight * 0.5,
                                          decoration: BoxDecoration(
                                            color: AppTheme.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: ListView.builder(
//                                        shrinkWrap: true,
//                                        physics:
//                                            const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                value.wasteCartItems.length,
                                            itemBuilder: (ctx, i) =>
                                                CollectDetailItem(
                                                    wasteItem:
                                                        value.wasteCartItems[i],
                                                    function: getWasteItems,
                                                    isNotActive: collect
                                                                .status.slug ==
                                                            'cancel' ||
                                                        collect.status.slug ==
                                                            'collected'),
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
                        ),
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
                        : _buildActionButtons(
                            context: context,
                            collect: collect,
                            deviceWidth: deviceWidth,
                            textScaleFactor: textScaleFactor,
                          ),
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _loadError ?? 'Something went wrong',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() => _loadError = null);
                _loadRequest();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressAndDateCard({
    required BuildContext context,
    required RequestWasteItem collect,
    required double textScaleFactor,
  }) {
    final addr = collect.address_data;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.addressLabel,
              style: TextStyle(
                fontFamily: 'Iransans',
                fontSize: textScaleFactor * 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 4),
            if (addr.name.trim().isNotEmpty)
              Text(
                addr.name,
                style: TextStyle(
                  fontFamily: 'Iransans',
                  fontSize: textScaleFactor * 14,
                  color: AppTheme.primary,
                ),
              ),
            if (addr.name.trim().isNotEmpty) const SizedBox(height: 4),
            Text(
              addr.address,
              style: TextStyle(
                fontFamily: 'Iransans',
                fontSize: textScaleFactor * 13,
              ),
            ),
            if (addr.latitude.isNotEmpty || addr.longitude.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${addr.latitude}, ${addr.longitude}',
                  style: TextStyle(
                    fontFamily: 'Iransans',
                    fontSize: textScaleFactor * 11,
                    color: AppTheme.grey,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              context.l10n.collectionLabel,
              style: TextStyle(
                fontFamily: 'Iransans',
                fontSize: textScaleFactor * 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${collect.collect_date.day} — ${collect.collect_date.time}',
              style: TextStyle(
                fontFamily: 'Iransans',
                fontSize: textScaleFactor * 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required RequestWasteItem collect,
    required double deviceWidth,
    required double textScaleFactor,
  }) {
    final bool isCompleted =
        collect.status.slug == 'cancel' || collect.status.slug == 'collected';

    if (isCompleted) {
      return Container(
        width: deviceWidth * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          collect.status.slug == 'collected'
              ? context.l10n.alreadyCollected
              : 'Request cancelled',
          style: TextStyle(
            fontFamily: 'Iransans',
            fontSize: textScaleFactor * 14,
            color: AppTheme.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: () => _onAcceptPressed(collect.id),
          child: Container(
            width: deviceWidth * 0.9,
            height: deviceWidth * 0.13,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Iransans',
                      fontSize: textScaleFactor * 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () => _onRejectPressed(collect.id),
          child: Container(
            width: deviceWidth * 0.9,
            height: deviceWidth * 0.13,
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Iransans',
                      fontSize: textScaleFactor * 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onAcceptPressed(int collectId) async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<Wastes>(context, listen: false)
          .acceptCollectRequest(collectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.requestSubmittedSuccess,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Iransans',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRejectPressed(int collectId) async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<Wastes>(context, listen: false)
          .rejectCollectRequest(collectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request rejected',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Iransans',
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
