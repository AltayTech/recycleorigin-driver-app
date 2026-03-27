import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/widgets/profile_view.dart';
import 'package:recycleorigindriver/features/home_feature/presentation/home_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class NavigationBottomScreen extends StatefulWidget {
  static const routeName = '/NBS';

  @override
  _NavigationBottomScreenState createState() => _NavigationBottomScreenState();
}

class _NavigationBottomScreenState extends State<NavigationBottomScreen> {
  int _selectedPageIndex = 0;

  void _selectBottomNavigationItem(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Future<bool> _onBackPressed() async {
    final l10n = context.l10n;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.exitDialogTitle,
          textAlign: TextAlign.center,
        ),
        content: Text(l10n.exitDialogMessage),
        actionsPadding: const EdgeInsets.all(10),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.noLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.yesLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(),
      HomeScreen(),
      HomeScreen(),
      ProfileView(),
    ];

    final currentPage = pages[_selectedPageIndex];

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.appBarTitle,
          ),
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: MainDrawer(),
        ),
        body: currentPage,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: _selectBottomNavigationItem,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.l10n.homeTabLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car),
              label: context.l10n.requestTabLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_shopping_cart),
              label: context.l10n.shopTabLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: context.l10n.profileTabLabel,
            ),
          ],
        ),
      ),
    );
  }
}
