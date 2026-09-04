import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_coordinator.dart';

class _FakeTracker implements DriverLocationTracker {
  int startCount = 0;
  int stopCount = 0;
  bool tracking = false;
  String? lastTitle;

  @override
  bool get isTracking => tracking;

  @override
  Future<void> start({
    String notificationTitle = LocationTrackingService.defaultNotificationTitle,
    String notificationText = LocationTrackingService.defaultNotificationText,
    String notificationChannelName =
        LocationTrackingService.defaultNotificationChannelName,
  }) async {
    startCount++;
    lastTitle = notificationTitle;
    tracking = true;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    tracking = false;
  }
}

DriverRoute _pendingRoute() {
  return DriverRoute(
    routeId: 1,
    generatedAt: DateTime.utc(2026, 1, 1),
    algorithm: 'test',
    depot: const RouteDepot(lat: 0, lng: 0),
    stops: const <RouteStop>[
      RouteStop(
        stopId: 1,
        sequence: 1,
        requestId: 1,
        customer: RouteCustomer(name: 'A', phone: ''),
        lat: 0,
        lng: 0,
        address: 'addr',
        status: 'pending',
      ),
    ],
  );
}

void main() {
  test('starts sharing for a loaded active route', () async {
    final tracker = _FakeTracker();
    final coordinator = RouteTrackingCoordinator(tracker);

    await coordinator.onRouteState(
      RouteState(status: RouteStatus.loaded, route: _pendingRoute()),
      notificationTitle: 'On route',
    );

    expect(tracker.startCount, 1);
    expect(tracker.stopCount, 0);
    expect(tracker.lastTitle, 'On route');
  });

  test('stops sharing when the route is empty', () async {
    final tracker = _FakeTracker()..tracking = true;
    final coordinator = RouteTrackingCoordinator(tracker);

    await coordinator.onRouteState(const RouteState(status: RouteStatus.empty));

    expect(tracker.stopCount, 1);
    expect(tracker.tracking, isFalse);
  });

  test('dispose does not stop sharing', () async {
    final tracker = _FakeTracker()..tracking = true;
    final coordinator = RouteTrackingCoordinator(tracker);

    coordinator.dispose();

    expect(tracker.stopCount, 0);
    expect(tracker.tracking, isTrue);
  });
}
