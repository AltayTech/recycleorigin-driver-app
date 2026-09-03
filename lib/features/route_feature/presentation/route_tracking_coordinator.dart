import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';

/// Syncs [LocationTrackingService] with route bloc state changes.
class RouteTrackingCoordinator {
  RouteTrackingCoordinator(this._tracking);

  final LocationTrackingService _tracking;

  void onRouteState(RouteState state) {
    if (shouldTrackDriverRoute(state)) {
      _tracking.start();
    } else {
      _tracking.stop();
    }
  }

  void dispose() {
    _tracking.stop();
  }
}
