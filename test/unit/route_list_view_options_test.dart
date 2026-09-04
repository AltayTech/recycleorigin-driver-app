import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_list_view_options.dart';

RouteStop _stop({
  required int id,
  required int sequence,
  required String status,
  DateTime? eta,
  double weightKg = 0,
  double lat = 0,
  double lng = 0,
}) {
  return RouteStop(
    stopId: id,
    sequence: sequence,
    requestId: id,
    customer: const RouteCustomer(name: 'A', phone: ''),
    lat: lat,
    lng: lng,
    address: 'addr $id',
    status: status,
    plannedArrival: eta,
    weightKg: weightKg,
  );
}

void main() {
  final pending = _stop(id: 1, sequence: 2, status: 'pending', weightKg: 1);
  final arrived = _stop(
    id: 2,
    sequence: 1,
    status: 'arrived',
    eta: DateTime.utc(2026, 1, 1, 10),
    weightKg: 5,
  );
  final skipped = _stop(id: 3, sequence: 3, status: 'skipped', weightKg: 2);
  final done = _stop(
    id: 4,
    sequence: 4,
    status: 'completed',
    eta: DateTime.utc(2026, 1, 1, 8),
    weightKg: 9,
  );

  test('filterStops keeps matching status', () {
    final all = <RouteStop>[pending, arrived, skipped, done];
    expect(filterStops(all, RouteStopStatusFilter.all), hasLength(4));
    expect(filterStops(all, RouteStopStatusFilter.skipped).single.stopId, 3);
    expect(filterStops(all, RouteStopStatusFilter.pending).single.stopId, 1);
  });

  test('sortStops by sequence uses solver order', () {
    final sorted = sortStops(<RouteStop>[
      pending,
      arrived,
    ], RouteStopSort.sequence);
    expect(sorted.map((s) => s.stopId).toList(), <int>[2, 1]);
  });

  test('sortStops by eta puts missing ETAs last', () {
    final sorted = sortStops(<RouteStop>[
      pending,
      arrived,
      done,
    ], RouteStopSort.eta);
    expect(sorted.map((s) => s.stopId).toList(), <int>[4, 2, 1]);
  });

  test('sortStops by weight is descending', () {
    final sorted = sortStops(<RouteStop>[
      pending,
      arrived,
      skipped,
    ], RouteStopSort.weight);
    expect(sorted.map((s) => s.stopId).toList(), <int>[2, 3, 1]);
  });

  test('sortStops by distance uses origin', () {
    final near = _stop(
      id: 10,
      sequence: 2,
      status: 'pending',
      lat: 41,
      lng: 29,
    );
    final far = _stop(id: 11, sequence: 1, status: 'pending', lat: 42, lng: 30);
    final sorted = sortStops(
      <RouteStop>[far, near],
      RouteStopSort.distance,
      origin: (lat: 41.0, lng: 29.0),
    );
    expect(sorted.map((s) => s.stopId).toList(), <int>[10, 11]);
  });

  test('sortStops by distance without origin keeps sequence', () {
    final sorted = sortStops(<RouteStop>[
      pending,
      arrived,
    ], RouteStopSort.distance);
    expect(sorted.map((s) => s.stopId).toList(), <int>[2, 1]);
  });

  test('routeWorkStops drops skipped', () {
    expect(routeWorkStops(<RouteStop>[pending, skipped, done]), hasLength(2));
  });

  test('canSkip and canInclude match status', () {
    expect(canSkipRouteStop('pending'), isTrue);
    expect(canSkipRouteStop('arrived'), isTrue);
    expect(canSkipRouteStop('completed'), isFalse);
    expect(canIncludeRouteStop('skipped'), isTrue);
    expect(canIncludeRouteStop('pending'), isFalse);
  });

  test('RouteStop.fromJson reads demand.weight_kg', () {
    final stop = RouteStop.fromJson(<String, dynamic>{
      'stop_id': 1,
      'sequence': 1,
      'request_id': 9,
      'customer': <String, dynamic>{'name': 'A', 'phone': ''},
      'lat': 1,
      'lng': 2,
      'address': 'x',
      'status': 'pending',
      'demand': <String, dynamic>{
        'weight_kg': 3.5,
        'items': <String>['paper'],
      },
    });
    expect(stop.weightKg, 3.5);
    expect(stop.items, <String>['paper']);
  });
}
