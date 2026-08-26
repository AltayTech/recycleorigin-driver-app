import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/core/models/shop.dart';

import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';

class AboutUsScreen extends StatefulWidget {
  static const routeName = '/AboutUsScreen';

  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  bool _isInit = true;

  late Shop shopData;

  bool _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await searchItems();
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(
          context.l10n.aboutUsLabel,
          style: TextStyle(fontSize: textScaleFactor * 18.0),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? SpinKitFadingCircle(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.onSurfaceVariant,
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
                          color: context.pageBackground,
                          child: FadeInImage(
                            placeholder: AssetImage('assets/images/circle.gif'),
                            image: NetworkImage(shopData.logo.sizes.medium),
                            fit: BoxFit.contain,
                            height: deviceWidth * 0.5,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          shopData.name,
                          style: TextStyle(
                            color: context.primaryText,
                            fontFamily: 'BFarnaz',
                            fontSize: textScaleFactor * 24.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          shopData.subject,
                          style: TextStyle(
                            color: context.secondaryText,
                            fontSize: textScaleFactor * 15.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            shopData.about,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: textScaleFactor * 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: deviceHeight * 0.7,
                        width: deviceWidth,
                        child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: shopData.features_list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_right,
                                    color: scheme.outlineVariant,
                                  ),
                                  Text(
                                    shopData.features_list[index].feature,
                                    style: TextStyle(
                                      color: context.primaryText,
                                      fontStyle: FontStyle.italic,
                                      fontSize: textScaleFactor * 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      drawer: mainDrawerIfRootRoute(context),
    );
  }
}
