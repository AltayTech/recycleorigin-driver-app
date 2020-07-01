import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:tamizshahrdriver/models/driver.dart';

import '../../models/customer.dart';
import '../../provider/app_theme.dart';
import '../../provider/customer_info.dart';
import 'customer_detail_info_edit_screen.dart';

class CustomerDetailInfoScreen extends StatefulWidget {
  final Customer customer;

  CustomerDetailInfoScreen({this.customer});

  @override
  _CustomerDetailInfoScreenState createState() =>
      _CustomerDetailInfoScreenState();
}

class _CustomerDetailInfoScreenState extends State<CustomerDetailInfoScreen> {
  Driver customer;
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
                              'اطلاعات شخصی',
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
                              'مشخصات',
                              style: TextStyle(
                                color: AppTheme.black,
                                fontFamily: 'Iransans',
                                fontSize: textScaleFactor * 14.0,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            FittedBox(
                              child: FlatButton(
                                color: AppTheme.primary,
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      CustomerDetailInfoEditScreen.routeName);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    Text(
                                      ' ویرایش',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Iransans',
                                        fontSize: textScaleFactor * 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              InfoItem(
                                title: 'نام',
                                text: customer.driver_data.fname,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: 'نام خانوادگی',
                                text: customer.driver_data.lname,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: 'نوع کاربر',
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
                                title: 'ایمیل',
                                text: customer.driver_data.email,
                                bgColor: Colors.white,
                                iconColor: Color(0xffA67FEC),
                              ),
                              InfoItem(
                                title: 'استان',
                                text: customer.driver_data.ostan != null
                                    ? customer.driver_data.ostan
                                    : '',
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                              InfoItem(
                                title: 'شهر',
                                text: customer.driver_data.city != null
                                    ? customer.driver_data.city
                                    : '',
                                bgColor: Colors.white,
                                iconColor: Color(0xff4392F1),
                              ),
                              InfoItem(
                                title: 'کدپستی',
                                text: customer.driver_data.postcode != null
                                    ? customer.driver_data.postcode
                                    : '',
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
    Key key,
    @required this.title,
    @required this.text,
    @required this.bgColor,
    @required this.iconColor,
  }) : super(key: key);

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
