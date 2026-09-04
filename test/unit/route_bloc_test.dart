import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/today_route_result.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';

DriverRoute _route(String status) {
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

class _FakeRouteRepository extends RouteRepository {
  _FakeRouteRepository() : super(ApiClient());

  final List<int> skippedIds = <int>[];
  late DriverRoute current = _route('pending');

  @override
  Future<Result<TodayRouteResult>> fetchTodayRoute({
    bool rebuild = false,
  }) async {
    return Success(TodayRouteResult(route: current));
  }

  @override
  Future<Result<void>> markSkipped(int stopId) async {
    skippedIds.add(stopId);
    current = _route('skipped');
    return const Success(null);
  }
}

void main() {
  blocTest<RouteBloc, RouteState>(
    'skip reloads today route as skipped',
    build: () => RouteBloc(_FakeRouteRepository()),
    act: (bloc) => bloc.add(RouteStopSkipped(1)),
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.status, RouteStatus.loaded);
      expect(bloc.state.route?.stops.single.status, 'skipped');
    },
  );

  test('fake repository records skip then reloads', () async {
    final repo = _FakeRouteRepository();
    final bloc = RouteBloc(repo);
    bloc.add(RouteStopSkipped(1));
    await bloc.stream.firstWhere((s) => s.status == RouteStatus.loaded);
    expect(repo.skippedIds, <int>[1]);
    expect(bloc.state.route?.stops.single.status, 'skipped');
    await bloc.close();
  });
}
