import 'package:flutter/material.dart';
import 'package:recycleorigindriver/models/personal_data.dart';
import 'package:recycleorigindriver/models/status.dart';

import '../../provider/app_theme.dart';
import '../../models/customer.dart';
import '../../screens/customer_info/customer_detail_info_screen.dart';
import '../../widgets/main_drawer.dart';

class CustomerUserInfoScreen extends StatefulWidget {
  static const routeName = '/customer_user_info_screen';

  CustomerUserInfoScreen();

  @override
  _CustomerUserInfoScreenState createState() => _CustomerUserInfoScreenState();
}

class _CustomerUserInfoScreenState extends State<CustomerUserInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: new IconThemeData(color: AppTheme.appBarIconColor),
      ),

      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors
              .transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: MainDrawer(),
      ), // resizeToAvoidBottomInset: false,
      body: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomerDetailInfoScreen(
            customer: Customer(
                id: 0,
                status: Status(
                  term_id: 0,
                  slug: '',
                  name: '',
                ),
                type: Status(
                  term_id: 0,
                  slug: '',
                  name: '',
                ),
                personalData: PersonalData(
                    phone: '', first_name: '', last_name: '', addresses: [])),
          )),
    );
  }
}
