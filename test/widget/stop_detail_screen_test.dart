import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/network/api_client.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/today_route_result.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/stop_detail_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

RouteStop _stop({required String status, DateTime? eta}) {
  return RouteStop(
    stopId: 1,
    sequence: 1,
    requestId: 1,
    customer: const RouteCustomer(name: 'reza mojed', phone: ''),
    lat: 0,
    lng: 0,
    address: 'Osmanbey1',
    status: status,
    plannedArrival: eta,
    weightKg: 2,
  );
}

class _FakeRouteRepository extends RouteRepository {
  _FakeRouteRepository() : super(ApiClient());

  @override
  Future<Result<TodayRouteResult>> fetchTodayRoute({
    bool rebuild = false,
  }) async {
    return const Success(TodayRouteResult());
  }
}

Future<void> _pumpStop(WidgetTester tester, {required RouteStop stop}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  final bloc = RouteBloc(_FakeRouteRepository());
  addTearDown(bloc.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<RouteBloc>.value(
        value: bloc,
        child: StopDetailScreen(stop: stop),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('pending stop shows next actions, not a completed state', (
    tester,
  ) async {
    await _pumpStop(
      tester,
      stop: _stop(
        status: 'pending',
        eta: DateTime(2026, 9, 5, 17, 41, 55, 162),
      ),
    );

    expect(find.text('Pending'), findsWidgets);
    expect(find.text("I've arrived"), findsOneWidget);
    expect(find.text('Mark complete'), findsOneWidget);
    expect(find.text("Couldn't complete"), findsOneWidget);
    expect(find.text('Failed'), findsNothing);
    expect(find.textContaining('17:41'), findsOneWidget);
    expect(find.textContaining('162'), findsNothing);
  });

  testWidgets('completed stop hides mutations and shows a done banner', (
    tester,
  ) async {
    await _pumpStop(tester, stop: _stop(status: 'completed'));

    expect(find.text('This stop is complete.'), findsOneWidget);
    expect(find.text('Mark complete'), findsNothing);
    expect(find.text("I've arrived"), findsNothing);
  });
}
