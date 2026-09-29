import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/route_sharing_notification.dart';

void main() {
  test('missing channel is created before Geolocator hides it', () {
    expect(
      routeSharingNoticeFor(null),
      RouteSharingNotice.prepareGeolocatorChannel,
    );
  });

  test('silent Geolocator channel needs our own notification', () {
    expect(
      routeSharingNoticeFor(Importance.none),
      RouteSharingNotice.postOwnNotification,
    );
  });

  test('a visible channel is left to Geolocator', () {
    expect(
      routeSharingNoticeFor(Importance.low),
      RouteSharingNotice.geolocatorAlreadyVisible,
    );
    expect(
      routeSharingNoticeFor(Importance.defaultImportance),
      RouteSharingNotice.geolocatorAlreadyVisible,
    );
  });
}
