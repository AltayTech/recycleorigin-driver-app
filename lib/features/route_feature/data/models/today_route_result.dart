import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';

/// Result of GET /driver/route/today (route may be absent).
class TodayRouteResult {
  const TodayRouteResult({this.route, this.emptyMessage});

  final DriverRoute? route;
  final String? emptyMessage;

  bool get hasRoute => route != null && route!.stops.isNotEmpty;
}
