import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_list_view_options.dart';

/// Whether live GPS tracking should run for the current route state.
bool shouldTrackDriverRoute(RouteState state) {
  if (state.status != RouteStatus.loaded || state.route == null) {
    return false;
  }
  return hasActiveRouteStops(state.route!);
}

/// True when at least one stop is still in progress.
bool hasActiveRouteStops(DriverRoute route) {
  return route.stops.any((stop) => !isInactiveRouteStopStatus(stop.status));
}

/// Whether an already-running tracker should stop after a route refresh.
///
/// A failed fetch must not stop sharing (transient network errors).
/// Sharing is never started here; that stays user-initiated.
bool shouldStopTrackingAfterRouteFetch({
  required bool isTracking,
  required bool fetchFailed,
  required DriverRoute? route,
}) {
  if (!isTracking || fetchFailed) {
    return false;
  }
  if (route == null) {
    return true;
  }
  return !hasActiveRouteStops(route);
}
