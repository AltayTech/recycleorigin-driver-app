import 'package:material_ui/material_ui.dart';
import 'package:recycleorigindriver/core/l10n/app_localizations_delegates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_map_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

DriverRoute _route() {
  return DriverRoute(
    routeId: 1,
    generatedAt: DateTime.utc(2026, 1, 1),
    algorithm: 'test',
    depot: const RouteDepot(lat: 41.01, lng: 28.97),
    stops: const <RouteStop>[
      RouteStop(
        stopId: 1,
        sequence: 1,
        requestId: 1,
        customer: RouteCustomer(name: 'A', phone: ''),
        lat: 41.02,
        lng: 28.98,
        address: 'Stop 1',
        status: 'pending',
      ),
      RouteStop(
        stopId: 2,
        sequence: 2,
        requestId: 2,
        customer: RouteCustomer(name: 'B', phone: ''),
        lat: 41.03,
        lng: 28.99,
        address: 'Stop 2',
        status: 'pending',
      ),
    ],
  );
}

void main() {
  testWidgets('shows route map tools without requesting GPS', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RouteMapScreen(route: _route()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Route map'), findsOneWidget);
    expect(find.byTooltip('My location'), findsOneWidget);
    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.byTooltip('Zoom out'), findsOneWidget);
    expect(find.byTooltip('Show whole route'), findsOneWidget);
    expect(find.text('OpenStreetMap'), findsOneWidget);
    expect(find.byTooltip('Depot'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.byTooltip('Show whole route'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
