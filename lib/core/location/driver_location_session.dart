import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/today_route_result.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';

/// Stops route location sharing on logout and when today's route is finished.
class DriverLocationSession extends StatefulWidget {
  const DriverLocationSession({
    super.key,
    required this.child,
    this.tracking,
    this.fetchTodayRoute,
  });

  final Widget child;

  /// Defaults to [LocationTrackingService.instance].
  final DriverLocationTracker? tracking;

  /// Defaults to GET /driver/route/today.
  final Future<Result<TodayRouteResult>> Function()? fetchTodayRoute;

  @override
  State<DriverLocationSession> createState() => _DriverLocationSessionState();
}

class _DriverLocationSessionState extends State<DriverLocationSession>
    with WidgetsBindingObserver {
  DriverLocationTracker get _tracking =>
      widget.tracking ?? LocationTrackingService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _stopIfRouteInactive();
    }
  }

  Future<void> _stopIfRouteInactive() async {
    if (!_tracking.isTracking) {
      return;
    }
    final fetch =
        widget.fetchTodayRoute ??
        () => RouteRepository(ApiProvider.client).fetchTodayRoute();
    final result = await fetch();
    if (!mounted) {
      return;
    }
    if (shouldStopTrackingAfterRouteFetch(
      isTracking: _tracking.isTracking,
      fetchFailed: result.isFailure,
      route: result.valueOrNull?.route,
    )) {
      await _tracking.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.isLoggedIn && !curr.isLoggedIn,
      listener: (context, state) {
        _tracking.stop();
      },
      child: widget.child,
    );
  }
}
