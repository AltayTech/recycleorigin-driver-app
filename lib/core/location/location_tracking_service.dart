import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigindriver/core/location/location_repository.dart';
import 'package:recycleorigindriver/core/location/position_upload_throttle.dart';
import 'package:recycleorigindriver/core/location/route_sharing_notification.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';

/// Starts and stops live GPS upload for an active driver route.
abstract interface class DriverLocationTracker {
  /// Begins the location stream and Android foreground notification.
  ///
  /// Does not show the OS permission prompt. Call [requestPermission]
  /// after the in-app disclosure if [hasPermission] is false.
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

  /// True when location services are on and while-in-use (or always)
  /// is already granted. Does not show a system prompt.
  Future<bool> hasPermission();

  /// Shows the OS location prompt (and Android notification if needed).
  Future<bool> requestPermission();

  /// True when the device location switch is already on.
  ///
  /// When it is off, opens system location settings and returns false.
  /// The settings screen is not waited on; call [hasPermission] again
  /// after the driver returns to the app.
  Future<bool> ensureLocationServices();

  /// Fires when [isTracking] changes, including a failed location stream.
  Listenable get trackingUpdates;
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
  final _TrackingUpdates _updates = _TrackingUpdates();
  Future<void> _chain = Future<void>.value();
  bool _tracking = false;

  @override
  bool get isTracking => _tracking;

  @override
  Listenable get trackingUpdates => _updates;

  /// Runs [action] after any in-flight start or stop.
  ///
  /// Geolocator's Android service drops the new stream when stop and start
  /// overlap, and reports that as location services being disabled.
  Future<void> _enqueue(Future<void> Function() action) {
    final next = _chain.then((_) => action());
    _chain = next.then((_) {}, onError: (_, _) {});
    return next;
  }

  @override
  Future<bool> hasPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    return _isGranted(await Geolocator.checkPermission());
  }

  @override
  Future<bool> ensureLocationServices() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      return true;
    }
    await Geolocator.openLocationSettings();
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    if (!await ensureLocationServices()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (!_isGranted(permission)) {
      permission = await Geolocator.requestPermission();
    }
    if (!_isGranted(permission)) {
      return false;
    }
    await _ensureNotificationPermission();
    return true;
  }

  bool _isGranted(LocationPermission permission) {
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
  }) {
    return _enqueue(
      () => _start(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
        notificationChannelName: notificationChannelName,
      ),
    );
  }

  Future<void> _start({
    required String notificationTitle,
    required String notificationText,
    required String notificationChannelName,
  }) async {
    if (_tracking) {
      return;
    }
    if (!await hasPermission()) {
      developer.log('Location permission denied; tracking skipped');
      return;
    }
    await _ensureNotificationPermission();

    final notice = await _prepareSharingNotification(notificationChannelName);
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
          onError: (Object error, StackTrace stackTrace) {
            unawaited(_enqueue(() => _abandonStream(error, stackTrace)));
          },
        );
    _tracking = true;
    _updates.ping();
    try {
      await RouteSharingNotification.instance.showIfNeeded(
        notice: notice,
        title: notificationTitle,
        body: notificationText,
        channelName: notificationChannelName,
      );
    } catch (e, st) {
      developer.log(
        'Could not show location notification: $e',
        error: e,
        stackTrace: st,
      );
    }
    developer.log('Driver location tracking started');
  }

  Future<RouteSharingNotice> _prepareSharingNotification(
    String channelName,
  ) async {
    try {
      return await RouteSharingNotification.instance.prepare(
        channelName: channelName,
      );
    } catch (e, st) {
      developer.log(
        'Could not prepare location notification: $e',
        error: e,
        stackTrace: st,
      );
      return RouteSharingNotice.postOwnNotification;
    }
  }

  @override
  Future<void> stop() {
    return _enqueue(_stop);
  }

  Future<void> _stop() async {
    if (!_tracking) {
      return;
    }
    await _releaseStream();
    developer.log('Driver location tracking stopped');
  }

  /// Drops a stream that already failed so [isTracking] is not left true.
  Future<void> _abandonStream(Object error, StackTrace stackTrace) async {
    if (!_tracking) {
      return;
    }
    developer.log(
      'Location stream error: $error',
      error: error,
      stackTrace: stackTrace,
    );
    await _releaseStream();
  }

  Future<void> _releaseStream() async {
    final subscription = _subscription;
    _subscription = null;
    _tracking = false;
    _updates.ping();
    await subscription?.cancel();
    await RouteSharingNotification.instance.dismiss();
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
        intervalDuration: const Duration(seconds: 10),
        // Fused location asks Play Services to resolve high-accuracy
        // settings. The foreground service often has no Activity, so that
        // resolution is reported as "location services disabled" even when
        // the device location switch is on. LocationManager does not.
        forceLocationManager: true,
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

class _TrackingUpdates extends ChangeNotifier {
  void ping() => notifyListeners();
}
