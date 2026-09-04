import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_coordinator.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_map_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/stop_detail_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Ordered list of today's route stops.
class RouteTodayScreen extends StatelessWidget {
  const RouteTodayScreen({super.key});

  static const routeName = '/route/today';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RouteBloc(RouteRepository(ApiProvider.client))
            ..add(RouteLoadRequested()),
      child: const _RouteTodayView(),
    );
  }
}

class _RouteTodayView extends StatefulWidget {
  const _RouteTodayView();

  @override
  State<_RouteTodayView> createState() => _RouteTodayViewState();
}

class _RouteTodayViewState extends State<_RouteTodayView> {
  late final RouteTrackingCoordinator _trackingCoordinator;
  bool _locationDenied = false;
  bool _sharingLocation = false;

  @override
  void initState() {
    super.initState();
    _trackingCoordinator = RouteTrackingCoordinator(
      LocationTrackingService.instance,
    );
  }

  @override
  void dispose() {
    _trackingCoordinator.dispose();
    super.dispose();
  }

  Future<void> _syncTracking(RouteState state) async {
    final l10n = context.l10n;
    await _trackingCoordinator.onRouteState(
      state,
      notificationTitle: l10n.routeLocationNotificationTitle,
      notificationText: l10n.routeLocationNotificationText,
      notificationChannelName: l10n.routeLocationNotificationChannel,
    );
    if (!mounted) {
      return;
    }
    final shouldTrack = shouldTrackDriverRoute(state);
    final sharing = LocationTrackingService.instance.isTracking;
    setState(() {
      _sharingLocation = sharing;
      _locationDenied = shouldTrack && !sharing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDev = AppConfig.environment == 'development' || kDebugMode;

    return BlocListener<RouteBloc, RouteState>(
      listener: (context, state) => _syncTracking(state),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.routeTodayTitle),
          actions: <Widget>[
            if (isDev)
              IconButton(
                tooltip: l10n.routeRebuildTooltip,
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<RouteBloc>().add(
                    RouteLoadRequested(rebuild: true),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () {
                final route = context.read<RouteBloc>().state.route;
                if (route != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RouteMapScreen(route: route),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            if (_locationDenied)
              MaterialBanner(
                content: Text(l10n.routeLocationPermissionBanner),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await _syncTracking(context.read<RouteBloc>().state);
                    },
                    child: Text(l10n.routeLocationPermissionAction),
                  ),
                ],
              ),
            if (_sharingLocation)
              Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.share_location,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.routeLocationSharingBanner,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: BlocBuilder<RouteBloc, RouteState>(
                builder: (context, state) {
                  if (state.status == RouteStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == RouteStatus.failure) {
                    return _MessagePanel(
                      icon: Icons.error_outline,
                      title: l10n.routeLoadErrorTitle,
                      body: state.message ?? l10n.routeUnknownError,
                      action: FilledButton(
                        onPressed: () =>
                            context.read<RouteBloc>().add(RouteLoadRequested()),
                        child: Text(l10n.retryLabel),
                      ),
                    );
                  }
                  if (state.status == RouteStatus.empty ||
                      state.route == null) {
                    return _MessagePanel(
                      icon: Icons.route_outlined,
                      title: l10n.routeEmptyTitle,
                      body: state.hint ?? l10n.routeEmptyBody,
                      action: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FilledButton(
                            onPressed: () => context.read<RouteBloc>().add(
                              RouteLoadRequested(),
                            ),
                            child: Text(l10n.refreshLabel),
                          ),
                          if (isDev) ...<Widget>[
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => context.read<RouteBloc>().add(
                                RouteLoadRequested(rebuild: true),
                              ),
                              child: Text(l10n.routeRebuildDevButton),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  final route = state.route!;
                  final completed = route.stops
                      .where((s) => s.status == 'completed')
                      .length;
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<RouteBloc>().add(RouteLoadRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: route.stops.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.routeStopsProgress(
                                    route.stops.length,
                                    completed,
                                  ),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: route.stops.isEmpty
                                      ? 0
                                      : completed / route.stops.length,
                                  color: context.brandPrimary,
                                ),
                              ],
                            ),
                          );
                        }
                        final stop = route.stops[index - 1];
                        return _StopCard(stop: stop);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: context.secondaryText),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            action,
          ],
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('${stop.sequence}')),
        title: Text(stop.address, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(stop.customer.name),
        trailing: StopStatusChip(status: stop.status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<RouteBloc>(),
                child: StopDetailScreen(stop: stop),
              ),
            ),
          );
        },
      ),
    );
  }
}
