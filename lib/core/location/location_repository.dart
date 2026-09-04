import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/utils/result.dart';

/// Posts driver GPS fixes to the backend.
class LocationRepository {
  LocationRepository(this._client);

  final ApiClient _client;

  Future<Result<void>> postPosition({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? recordedAt,
  }) {
    return _client.post<void>(
      Urls.driverLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        if (recordedAt != null)
          'recorded_at': recordedAt.toUtc().toIso8601String(),
      },
      parser: (_) {},
    );
  }
}
