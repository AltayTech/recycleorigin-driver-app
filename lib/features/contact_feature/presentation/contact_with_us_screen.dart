import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';

class ContactWithUs extends StatefulWidget {
  static const routeName = '/ContactWithUs';

  @override
  _ContactWithUsState createState() => _ContactWithUsState();
}

class _ContactWithUsState extends State<ContactWithUs> {
  bool _isLoading = false;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isInit = true;

  late Shop shopData;

  List<String> aboutInfotitle = [];

  List<String> aboutInfoContent = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();

      aboutInfoContent = [
        shopData.about,
        shopData.return_policy,
        shopData.privacy,
        shopData.how_to_order,
        shopData.faq,
        shopData.pay_methods_desc
      ];
      aboutInfotitle = [
        context.l10n.aboutStoreLabel,
        context.l10n.returnPolicyLabel,
        context.l10n.privacyPolicyLabel,
        context.l10n.howToOrderLabel,
        context.l10n.faqLabel,
        context.l10n.paymentMethodLabel,
      ];
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> searchItems() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<CustomerInfoBloc>().fetchShopData();
    shopData = context.read<CustomerInfoBloc>().state.shop!;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    shopData = context.watch<CustomerInfoBloc>().state.shop!;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          context.l10n.contactUsLabel,
          style: TextStyle(
            color: AppTheme.bg,
            fontSize: textScaleFactor * 18.0,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: _isLoading
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
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: deviceWidth * 0.3,
                        height: deviceWidth * 0.3,
                        color: AppTheme.bg,
                        child: FadeInImage(
                          placeholder: AssetImage('assets/images/circle.gif'),
                          image: NetworkImage(shopData.logo.sizes.medium),
                          fit: BoxFit.contain,
                          height: deviceWidth * 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          shopData.name,
                          style: TextStyle(
                            color: AppTheme.h1,
                            fontFamily: 'BFarnaz',
                            fontSize: textScaleFactor * 24.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(),
                      Column(
                        children: <Widget>[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      shopData.address,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: textScaleFactor * 18,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.call,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      EnArConvertor().replaceArNumber(
                                        shopData.support_phone,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: textScaleFactor * 18,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.smartphone,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      EnArConvertor()
                                          .replaceArNumber(shopData.mobile),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: textScaleFactor * 18,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: deviceHeight * 0.10,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 8,
                                      child: InkWell(
                                        onTap: () {
                                          _launchURL(
                                              shopData.social_media.instagram);
                                        },
                                        child: Image.asset(
                                            'assets/images/instagram.png'),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: InkWell(
                                          onTap: () {
                                            _launchURL(
                                                shopData.social_media.telegram);
                                          },
                                          child: Image.asset(
                                              'assets/images/telegram.png')),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
