import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recycleorigindriver/core/location/location_repository.dart';
import 'package:recycleorigindriver/core/location/position_upload_throttle.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';

/// Streams GPS fixes while the driver is on an active route and uploads them.
class LocationTrackingService {
  LocationTrackingService._();

  static final LocationTrackingService instance = LocationTrackingService._();

  LocationRepository? _repository;
  StreamSubscription<Position>? _subscription;
  final PositionUploadThrottle _throttle = PositionUploadThrottle();
  bool _tracking = false;

  bool get isTracking => _tracking;

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.android &&
        permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> start() async {
    if (_tracking) {
      return;
    }
    final allowed = await ensurePermission();
    if (!allowed) {
      developer.log('Location permission denied; tracking skipped');
      return;
    }

    _repository ??= LocationRepository(ApiProvider.client);
    _throttle.reset();
    final settings = _locationSettings();
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: (Object e, StackTrace st) {
          developer.log('Location stream error: $e', error: e, stackTrace: st);
        });
    _tracking = true;
    developer.log('Driver location tracking started');
  }

  Future<void> stop() async {
    if (!_tracking) {
      return;
    }
    await _subscription?.cancel();
    _subscription = null;
    _tracking = false;
    developer.log('Driver location tracking stopped');
  }

  LocationSettings _locationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'RecycleOrigin Driver',
          notificationText: 'Sharing your location while on route',
          enableWakeLock: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 50,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );
  }

  Future<void> _onPosition(Position position) async {
    final now = DateTime.now().toUtc();
    if (!_throttle.shouldUpload(now)) {
      return;
    }
    final repo = _repository;
    if (repo == null) {
      return;
    }
    final result = await repo.postPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      recordedAt: position.timestamp,
    );
    if (result.isSuccess) {
      _throttle.markUploaded(now);
    }
  }
}
