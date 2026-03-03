import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recycleorigindriver/models/driver.dart';

import '../../models/customer.dart';
import '../../l10n/l10n.dart';
import '../../provider/app_theme.dart';
import '../../provider/customer_info.dart';

class CustomerDetailInfoScreen extends StatefulWidget {
  final Customer customer;

  CustomerDetailInfoScreen({required this.customer});

  @override
  _CustomerDetailInfoScreenState createState() =>
      _CustomerDetailInfoScreenState();
}

class _CustomerDetailInfoScreenState extends State<CustomerDetailInfoScreen> {
  late Driver customer;
  var _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      cashOrder();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> cashOrder() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<CustomerInfo>(context, listen: false).getCustomer();
    customer = Provider.of<CustomerInfo>(context, listen: false).driver;

    setState(() {
      _isLoading = false;
      print(_isLoading.toString());
    });
    print(_isLoading.toString());
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: _isLoading
            ? Align(
                alignment: Alignment.center,
                child: SpinKitFadingCircle(
                  itemBuilder: (BuildContext context, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index.isEven ? Colors.grey : Colors.grey,
                      ),
                    );
                  },
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/user_Icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              context.l10n.personalInfoLabel,
                              style: TextStyle(
                                color: AppTheme.h1,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 18.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              context.l10n.specificationsLabel,
                              style: TextStyle(
                                color: AppTheme.black,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 14.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
//                            FittedBox(
//                              child: FlatButton(
//                                color: AppTheme.primary,
//                                onPressed: () {
//                                  Navigator.of(context).pushReplacementNamed(
//                                      CustomerDetailInfoEditScreen.routeName);
//                                },
//                                child: Row(
//                                  children: <Widget>[
//                                    Icon(
//                                      Icons.edit,
//                                      color: Colors.white,
//                                      size: 16,
//                                    ),
//                                    Text(
//                                      ' ویرایش',
//                                      style: TextStyle(
//                                        color: Colors.white,
//                                        fontFamily: 'Iransans',
//                                        fontSize: textScaleFactor * 14.0,
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ),
                          ],
                        ),
                        Container(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              InfoItem(
                                title: context.l10n.firstNameLabel,
                                text: customer.driver_data.fname,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: context.l10n.lastNameLabel,
                                text: customer.driver_data.lname,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: context.l10n.userTypeLabel,
                                text: customer.status.name,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                        ),
                        Container(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              InfoItem(
                                title: context.l10n.emailLabel,
                                text: customer.driver_data.email,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: context.l10n.provinceLabel,
                                text: customer.driver_data.ostan != null
                                    ? customer.driver_data.ostan
                                    : '',
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                              InfoItem(
                                title: context.l10n.cityLabel,
                                text: customer.driver_data.city != null
                                    ? customer.driver_data.city
                                    : '',
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                              InfoItem(
                                title: context.l10n.postalCodeLabel,
                                text: customer.driver_data.postcode != null
                                    ? customer.driver_data.postcode
                                    : '',
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                        ),
                        Container(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              InfoItem(
                                title: context.l10n.vehicleTypeLabel,
                                text: customer.car.name,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: context.l10n.vehicleColorLabel,
                                text: customer.car_color.name,
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                              InfoItem(
                                title: context.l10n.plateNumberLabel,
                                text: customer.car_number,
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: deviceHeight * 0.02,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    required this.title,
    required this.text,
    required this.bgColor,
    required this.iconColor,
  }) ;

  final String title;
  final String text;
  final Color bgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title : ',
            style: TextStyle(
              color: AppTheme.grey,
              fontFamily: 'Iransans',
              fontSize: textScaleFactor * 14.0,
            ),
          ),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                    color: Colors.grey.withOpacity(
                  0.0,
                )),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppTheme.black,
                    fontFamily: 'Iransans',
                    fontSize: textScaleFactor * 14.0,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
