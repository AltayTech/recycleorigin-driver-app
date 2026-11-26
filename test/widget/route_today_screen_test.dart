import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:recycleorigindriver/core/l10n/app_localizations_delegates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/today_route_result.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_today_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

DriverRoute _pendingRoute() {
  return DriverRoute(
    routeId: 1,
    generatedAt: DateTime.utc(2026, 1, 1),
    algorithm: 'test',
    depot: const RouteDepot(lat: 0, lng: 0),
    stops: const <RouteStop>[
      RouteStop(
        stopId: 1,
        sequence: 1,
        requestId: 1,
        customer: RouteCustomer(name: 'A', phone: ''),
        lat: 0,
        lng: 0,
        address: 'Osmanbey1',
        status: 'pending',
      ),
    ],
  );
}

class _FakeRouteRepository extends RouteRepository {
  _FakeRouteRepository() : super(ApiClient());

  @override
  Future<Result<TodayRouteResult>> fetchTodayRoute({
    bool rebuild = false,
  }) async {
    return Success(TodayRouteResult(route: _pendingRoute()));
  }
}

class _FakeTracker implements DriverLocationTracker {
  _FakeTracker({this.granted = false});

  bool granted;
  bool tracking = false;
  int startCount = 0;
  int requestCount = 0;
  bool grantOnRequest = true;

  @override
  bool get isTracking => tracking;

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    granted = grantOnRequest;
    return granted;
  }

  @override
  Future<void> start({
    String notificationTitle = LocationTrackingService.defaultNotificationTitle,
    String notificationText = LocationTrackingService.defaultNotificationText,
    String notificationChannelName =
        LocationTrackingService.defaultNotificationChannelName,
  }) async {
    startCount++;
    tracking = granted;
  }

  @override
  Future<void> stop() async {
    tracking = false;
  }

  @override
  Future<bool> ensureLocationServices() async => true;

  @override
  final Listenable trackingUpdates = ChangeNotifier();
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required _FakeTracker tracker,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RouteTodayScreen(
        tracking: tracker,
        repository: _FakeRouteRepository(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('active route without permission shows disclosure first', (
    tester,
  ) async {
    final tracker = _FakeTracker();
    await _pumpRoute(tester, tracker: tracker);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('precise location'), findsOneWidget);
    expect(find.textContaining('when the app is not in use'), findsOneWidget);
    expect(tracker.startCount, 0);
    expect(
      find.textContaining('Your precise location is being shared'),
      findsNothing,
    );
  });

  testWidgets('Continue then grant starts sharing', (tester) async {
    final tracker = _FakeTracker();
    await _pumpRoute(tester, tracker: tracker);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(tracker.requestCount, 1);
    expect(tracker.startCount, 1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.textContaining('Your precise location is being shared'),
      findsOneWidget,
    );
  });

  testWidgets('Not now shows Enable banner and does not start sharing', (
    tester,
  ) async {
    final tracker = _FakeTracker();
    await _pumpRoute(tester, tracker: tracker);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(tracker.requestCount, 0);
    expect(tracker.startCount, 0);
    expect(find.text('Enable'), findsOneWidget);
    expect(
      find.textContaining('Your precise location is being shared'),
      findsNothing,
    );
  });

  testWidgets('already granted skips disclosure and starts sharing', (
    tester,
  ) async {
    final tracker = _FakeTracker(granted: true);
    await _pumpRoute(tester, tracker: tracker);

    expect(find.byType(AlertDialog), findsNothing);
    expect(tracker.requestCount, 0);
    expect(tracker.startCount, 1);
    expect(
      find.textContaining('Your precise location is being shared'),
      findsOneWidget,
    );
  });
}
