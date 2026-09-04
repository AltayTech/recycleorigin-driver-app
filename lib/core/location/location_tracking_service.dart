import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigindriver/core/location/location_repository.dart';
import 'package:recycleorigindriver/core/location/position_upload_throttle.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';

/// Starts and stops live GPS upload for an active driver route.
abstract interface class DriverLocationTracker {
  /// Begins the location stream and Android foreground notification.
  Future<void> start({
    String notificationTitle = LocationTrackingService.defaultNotificationTitle,
    String notificationText = LocationTrackingService.defaultNotificationText,
    String notificationChannelName =
        LocationTrackingService.defaultNotificationChannelName,
  });

  /// Stops the stream and dismisses the foreground notification.
  Future<void> stop();

  /// Whether a location stream is currently running.
  bool get isTracking;
}

/// Streams GPS fixes while the driver is on an active route and uploads them.
class LocationTrackingService implements DriverLocationTracker {
  LocationTrackingService._();

  /// Process-wide tracker used by the route screen and session host.
  static final LocationTrackingService instance = LocationTrackingService._();

  /// Fallback title if l10n is not available yet.
  static const String defaultNotificationTitle = 'RecycleOrigin Driver';

  /// Fallback body shown in the ongoing status-bar notification.
  static const String defaultNotificationText =
      'Sharing your location with dispatch while on route';

  /// Fallback Android notification channel name (system settings).
  static const String defaultNotificationChannelName =
      'On-route location sharing';

  LocationRepository? _repository;
  StreamSubscription<Position>? _subscription;
  final PositionUploadThrottle _throttle = PositionUploadThrottle();
  bool _tracking = false;

  @override
  bool get isTracking => _tracking;

  /// Requests location (and on Android, notification) permission.
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
    await _ensureNotificationPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _ensureNotificationPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied) {
      return;
    }
    await Permission.notification.request();
  }

  @override
  Future<void> start({
    String notificationTitle = defaultNotificationTitle,
    String notificationText = defaultNotificationText,
    String notificationChannelName = defaultNotificationChannelName,
  }) async {
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
    final settings = _locationSettings(
      notificationTitle: notificationTitle,
      notificationText: notificationText,
      notificationChannelName: notificationChannelName,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          _onPosition,
          onError: (Object e, StackTrace st) {
            developer.log(
              'Location stream error: $e',
              error: e,
              stackTrace: st,
            );
          },
        );
    _tracking = true;
    developer.log('Driver location tracking started');
  }

  @override
  Future<void> stop() async {
    if (!_tracking) {
      return;
    }
    await _subscription?.cancel();
    _subscription = null;
    _tracking = false;
    developer.log('Driver location tracking stopped');
  }

  LocationSettings _locationSettings({
    required String notificationTitle,
    required String notificationText,
    required String notificationChannelName,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          notificationChannelName: notificationChannelName,
          notificationIcon: const AndroidResource(
            name: 'ic_stat_location_sharing',
            defType: 'drawable',
          ),
          enableWakeLock: true,
          setOngoing: true,
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
