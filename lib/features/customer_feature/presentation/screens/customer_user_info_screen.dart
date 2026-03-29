import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_detail_info_edit_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/screens/customer_detail_info_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class CustomerUserInfoScreen extends StatefulWidget {
  static const routeName = '/customer_user_info_screen';

  @override
  State<CustomerUserInfoScreen> createState() => _CustomerUserInfoScreenState();
}

class _CustomerUserInfoScreenState extends State<CustomerUserInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CustomerInfoBloc>().getCustomer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n.personalInfoLabel,
          style: const TextStyle(fontFamily: 'Iransans'),
        ),
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.editProfileLabel,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(
                CustomerDetailInfoEditScreen.routeName,
              );
            },
          ),
        ],
      ),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: MainDrawer(),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomerDetailInfoScreen(),
      ),
    );
  }
}
