import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/today_route_result.dart';

/// Fetches driver route data from the backend.
class RouteRepository {
  RouteRepository(this._client);

  final ApiClient _client;

  Future<Result<TodayRouteResult>> fetchTodayRoute(
      {bool rebuild = false}) async {
    if (rebuild) {
      final rebuildResult = await _client.post<void>(
        Urls.driverRouteRebuild,
        parser: (_) {},
      );
      if (rebuildResult.isFailure) {
        return Failure(rebuildResult.errorOrNull ?? 'Rebuild failed');
      }
    }
    return _client.get<TodayRouteResult>(
      Urls.driverRouteToday,
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          return const TodayRouteResult(
            emptyMessage: 'Unexpected response from server',
          );
        }
        final dynamic id = data['route_id'];
        if (id == null) {
          return TodayRouteResult(
            emptyMessage:
                data['message'] as String? ?? 'No route available yet',
          );
        }
        if (id is num && id == 0) {
          return TodayRouteResult(
            emptyMessage:
                data['message'] as String? ?? 'No route available yet',
          );
        }
        final route = DriverRoute.fromJson(data);
        if (route.stops.isEmpty) {
          return TodayRouteResult(
            emptyMessage:
                data['message'] as String? ?? 'No stops on this route',
          );
        }
        return TodayRouteResult(route: route);
      },
    );
  }

  Future<Result<void>> markArrived(int stopId) => _mark(stopId, 'arrived');

  Future<Result<void>> markCompleted(int stopId) => _mark(stopId, 'completed');

  Future<Result<void>> markFailed(int stopId, {String reason = ''}) =>
      _mark(stopId, 'failed', body: <String, dynamic>{'reason': reason});

  Future<Result<void>> _mark(
    int stopId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    return _client.post<void>(
      Urls.driverRouteStopAction(stopId, action),
      data: body ?? <String, dynamic>{},
      parser: (_) {},
    );
  }
}
