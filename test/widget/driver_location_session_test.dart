import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/driver_location_session.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';

import '../support/fake_auth_bloc.dart';

class _SessionAuth extends FakeAuthBloc {
  void logIn() {
    emit(state.copyWith(isLoggedIn: true, token: 't'));
  }

  void logOut() {
    emit(state.copyWith(isLoggedIn: false, token: ''));
  }
}

class _FakeTracker implements DriverLocationTracker {
  int stopCount = 0;

  @override
  bool isTracking = true;

  @override
  Future<void> start({
    String notificationTitle = LocationTrackingService.defaultNotificationTitle,
    String notificationText = LocationTrackingService.defaultNotificationText,
    String notificationChannelName =
        LocationTrackingService.defaultNotificationChannelName,
  }) async {}

  @override
  Future<void> stop() async {
    stopCount++;
    isTracking = false;
  }
}

void main() {
  testWidgets('stops location sharing when the driver signs out', (
    tester,
  ) async {
    final auth = _SessionAuth()..logIn();
    final tracker = _FakeTracker();

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: auth,
        child: DriverLocationSession(
          tracking: tracker,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    auth.logOut();
    await tester.pump();

    expect(tracker.stopCount, 1);
    expect(tracker.isTracking, isFalse);
  });
}
