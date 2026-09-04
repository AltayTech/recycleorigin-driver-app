import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';

/// Syncs [DriverLocationTracker] with route bloc state changes.
class RouteTrackingCoordinator {
  RouteTrackingCoordinator(this._tracking);

  final DriverLocationTracker _tracking;

  /// Starts sharing when the route has work left; stops when it does not.
  Future<void> onRouteState(
    RouteState state, {
    String notificationTitle = LocationTrackingService.defaultNotificationTitle,
    String notificationText = LocationTrackingService.defaultNotificationText,
    String notificationChannelName =
        LocationTrackingService.defaultNotificationChannelName,
  }) async {
    if (shouldTrackDriverRoute(state)) {
      await _tracking.start(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
        notificationChannelName: notificationChannelName,
      );
    } else {
      await _tracking.stop();
    }
  }

  /// Does not stop GPS. Sharing must continue when the driver leaves My route
  /// or backgrounds the app (Play foreground-service location policy).
  void dispose() {}
}
