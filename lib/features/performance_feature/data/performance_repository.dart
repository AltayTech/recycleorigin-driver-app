import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/performance_feature/data/performance_models.dart';

/// Loads driver performance stats from the backend.
class PerformanceRepository {
  PerformanceRepository([ApiClient? client])
      : _client = client ?? ApiProvider.client;

  final ApiClient _client;

  Future<Result<PerformanceData>> fetchPerformance({String range = '30d'}) {
    return _client.get<PerformanceData>(
      '${Urls.rootUrl}${Urls.statsImpactEndPoint}',
      queryParameters: <String, dynamic>{'range': range},
      parser: (dynamic data) =>
          PerformanceData.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Result<LeaderboardData>> fetchLeaderboard({
    String range = '30d',
    String metric = 'pickups',
    int limit = 20,
  }) {
    return _client.get<LeaderboardData>(
      '${Urls.rootUrl}${Urls.statsLeaderboardEndPoint}',
      queryParameters: <String, dynamic>{
        'range': range,
        'metric': metric,
        'limit': limit,
      },
      parser: (dynamic data) =>
          LeaderboardData.fromJson(data as Map<String, dynamic>),
    );
  }
}
