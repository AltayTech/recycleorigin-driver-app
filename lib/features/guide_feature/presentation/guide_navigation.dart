import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/navigation/driver_shell_tab_request.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_today_screen.dart';
import 'package:recycleorigindriver/features/support_tickets/presentation/driver_support_tickets_list_screen.dart';

/// Switches the driver shell to [tabIndex] and returns to the main scaffold.
void navigateToDriverShellTab(BuildContext context, int tabIndex) {
  driverShellTabRequest.value = tabIndex;
  Navigator.of(context).popUntil(
    (route) => route.settings.name == NavigationBottomScreen.routeName,
  );
}

/// Opens today's route screen.
void navigateToRouteToday(BuildContext context) {
  Navigator.of(context).pushNamed(RouteTodayScreen.routeName);
}

/// Opens the support tickets list.
void navigateToSupportTickets(BuildContext context) {
  Navigator.of(context).pushNamed(DriverSupportTicketsListScreen.routeName);
}
