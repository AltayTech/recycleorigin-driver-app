import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/models/driver.dart';

import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';

/// Read-only driver profile (name, contact, address, vehicle summary).
class CustomerDetailInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
      buildWhen: (prev, cur) => prev.driver != cur.driver,
      builder: (context, state) {
        final d = state.driver;
        return _DriverProfileBody(driver: d);
      },
    );
  }
}

class _DriverProfileBody extends StatelessWidget {
  const _DriverProfileBody({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: SingleChildScrollView(
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
                          fontSize: textScaleFactor * 18.0,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      context.l10n.specificationsLabel,
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: textScaleFactor * 14.0,
                      ),
                    ),
                  ),
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      InfoItem(
                        title: context.l10n.firstNameLabel,
                        text: driver.driver_data.fname,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.lastNameLabel,
                        text: driver.driver_data.lname,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.userTypeLabel,
                        text: driver.status.name,
                        bgColor: Colors.white,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white),
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      InfoItem(
                        title: context.l10n.emailLabel,
                        text: driver.driver_data.email,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.provinceLabel,
                        text: driver.driver_data.ostan,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.cityLabel,
                        text: driver.driver_data.city,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.postalCodeLabel,
                        text: driver.driver_data.postcode,
                        bgColor: Colors.white,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white),
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      InfoItem(
                        title: context.l10n.vehicleTypeLabel,
                        text: driver.car.name,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.vehicleColorLabel,
                        text: driver.car_color.name,
                        bgColor: Colors.white,
                      ),
                      InfoItem(
                        title: context.l10n.plateNumberLabel,
                        text: driver.car_number,
                        bgColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: deviceHeight * 0.02),
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
  });

  final String title;
  final String text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title : ',
            style: TextStyle(
              color: AppTheme.grey,
              fontSize: textScaleFactor * 14.0,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.grey.withOpacity(0.0)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text.isEmpty ? '—' : text,
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: textScaleFactor * 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
