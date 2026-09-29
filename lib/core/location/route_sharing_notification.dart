import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// How to keep the on-route notification visible on Android.
enum RouteSharingNotice {
  /// Channel does not exist yet. Create it as visible before Geolocator.
  prepareGeolocatorChannel,

  /// Geolocator will post a notification the user can already see.
  geolocatorAlreadyVisible,

  /// Geolocator channel is stuck at "none" and cannot be upgraded.
  postOwnNotification,
}

/// Geolocator's foreground channel id. It is created at importance none,
/// which hides the notification while the driver is using the app.
const String geolocatorLocationChannelId = 'geolocator_channel_01';

/// Decides how to show the sharing notification for an existing channel.
RouteSharingNotice routeSharingNoticeFor(Importance? importance) {
  if (importance == null) {
    return RouteSharingNotice.prepareGeolocatorChannel;
  }
  if (importance == Importance.none) {
    return RouteSharingNotice.postOwnNotification;
  }
  return RouteSharingNotice.geolocatorAlreadyVisible;
}

/// Shows the ongoing "location sharing" notification while tracking runs.
class RouteSharingNotification {
  RouteSharingNotification._();

  static final RouteSharingNotification instance = RouteSharingNotification._();

  static const int _notificationId = 75416;
  static const String _fallbackChannelId = 'driver_route_location';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Creates a visible Geolocator channel when needed.
  ///
  /// Returns whether this class must post its own notification because the
  /// plugin channel was already created as silent.
  Future<RouteSharingNotice> prepare({required String channelName}) async {
    if (!_isAndroid) {
      return RouteSharingNotice.geolocatorAlreadyVisible;
    }
    final android = _android;
    if (android == null) {
      return RouteSharingNotice.postOwnNotification;
    }
    final channels = await android.getNotificationChannels();
    final existing = _channel(channels, geolocatorLocationChannelId);
    final notice = routeSharingNoticeFor(existing?.importance);
    if (notice == RouteSharingNotice.prepareGeolocatorChannel) {
      await android.createNotificationChannel(
        _channelSpec(geolocatorLocationChannelId, channelName),
      );
    }
    return notice;
  }

  /// Posts a visible ongoing notification when Geolocator's own is hidden.
  Future<void> showIfNeeded({
    required RouteSharingNotice notice,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (notice != RouteSharingNotice.postOwnNotification || !_isAndroid) {
      return;
    }
    final android = _android;
    if (android == null) {
      return;
    }
    await android.createNotificationChannel(
      _channelSpec(_fallbackChannelId, channelName),
    );
    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _fallbackChannelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ongoing: true,
          autoCancel: false,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
          icon: 'ic_stat_location_sharing',
          category: AndroidNotificationCategory.navigation,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  /// Removes the fallback notification. Geolocator dismisses its own.
  Future<void> dismiss() async {
    if (!_isAndroid) {
      return;
    }
    await _plugin.cancel(id: _notificationId);
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  AndroidNotificationChannel? _channel(
    List<AndroidNotificationChannel>? channels,
    String id,
  ) {
    if (channels == null) {
      return null;
    }
    for (final channel in channels) {
      if (channel.id == id) {
        return channel;
      }
    }
    return null;
  }

  AndroidNotificationChannel _channelSpec(String id, String name) {
    return AndroidNotificationChannel(
      id,
      name,
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );
  }
}
