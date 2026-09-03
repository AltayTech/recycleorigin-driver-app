import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';

/// Whether live GPS tracking should run for the current route state.
bool shouldTrackDriverRoute(RouteState state) {
  if (state.status != RouteStatus.loaded || state.route == null) {
    return false;
  }
  return hasActiveRouteStops(state.route!);
}

/// True when at least one stop is still in progress.
bool hasActiveRouteStops(DriverRoute route) {
  return route.stops.any(
    (stop) => stop.status != 'completed' && stop.status != 'failed',
  );
}
