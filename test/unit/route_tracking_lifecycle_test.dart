import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';

DriverRoute _routeWith(String status) {
  return DriverRoute(
    routeId: 1,
    generatedAt: DateTime.utc(2026, 1, 1),
    algorithm: 'test',
    depot: const RouteDepot(lat: 0, lng: 0),
    stops: <RouteStop>[
      RouteStop(
        stopId: 1,
        sequence: 1,
        requestId: 1,
        customer: const RouteCustomer(name: 'A', phone: ''),
        lat: 0,
        lng: 0,
        address: 'addr',
        status: status,
      ),
    ],
  );
}

void main() {
  group('hasActiveRouteStops', () {
    test('true for pending stop', () {
      expect(hasActiveRouteStops(_routeWith('pending')), isTrue);
    });

    test('true for arrived stop', () {
      expect(hasActiveRouteStops(_routeWith('arrived')), isTrue);
    });

    test('false when every stop is completed or failed', () {
      expect(hasActiveRouteStops(_routeWith('completed')), isFalse);
      expect(hasActiveRouteStops(_routeWith('failed')), isFalse);
    });
  });

  group('shouldTrackDriverRoute', () {
    test('false until route is loaded', () {
      expect(shouldTrackDriverRoute(const RouteState()), isFalse);
      expect(
        shouldTrackDriverRoute(const RouteState(status: RouteStatus.loading)),
        isFalse,
      );
    });

    test('true for a loaded route with work left', () {
      expect(
        shouldTrackDriverRoute(
          RouteState(status: RouteStatus.loaded, route: _routeWith('pending')),
        ),
        isTrue,
      );
    });
  });

  group('shouldStopTrackingAfterRouteFetch', () {
    test('does not stop when not tracking', () {
      expect(
        shouldStopTrackingAfterRouteFetch(
          isTracking: false,
          fetchFailed: false,
          route: null,
        ),
        isFalse,
      );
    });

    test('does not stop when the fetch failed', () {
      expect(
        shouldStopTrackingAfterRouteFetch(
          isTracking: true,
          fetchFailed: true,
          route: null,
        ),
        isFalse,
      );
    });

    test('stops when there is no route', () {
      expect(
        shouldStopTrackingAfterRouteFetch(
          isTracking: true,
          fetchFailed: false,
          route: null,
        ),
        isTrue,
      );
    });

    test('stops when all stops are done', () {
      expect(
        shouldStopTrackingAfterRouteFetch(
          isTracking: true,
          fetchFailed: false,
          route: _routeWith('completed'),
        ),
        isTrue,
      );
    });

    test('keeps sharing while a stop is active', () {
      expect(
        shouldStopTrackingAfterRouteFetch(
          isTracking: true,
          fetchFailed: false,
          route: _routeWith('pending'),
        ),
        isFalse,
      );
    });
  });
}
