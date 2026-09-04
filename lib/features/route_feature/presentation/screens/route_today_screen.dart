import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_list_view_options.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_coordinator.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_tracking_lifecycle.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_map_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/stop_detail_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
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
  RouteStopStatusFilter _filter = RouteStopStatusFilter.all;
  RouteStopSort _sort = RouteStopSort.sequence;
  GeoOrigin? _sortOrigin;

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

  Future<void> _showSortSheet(AppLocalizations l10n) async {
    var picked = _sort;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: RadioGroup<RouteStopSort>(
              groupValue: picked,
              onChanged: (v) {
                if (v != null) {
                  picked = v;
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.routeListSortSheetTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<RouteStopSort>(
                    title: Text(l10n.routeListSortSequence),
                    value: RouteStopSort.sequence,
                  ),
                  RadioListTile<RouteStopSort>(
                    title: Text(l10n.routeListSortEta),
                    value: RouteStopSort.eta,
                  ),
                  RadioListTile<RouteStopSort>(
                    title: Text(l10n.routeListSortWeight),
                    value: RouteStopSort.weight,
                  ),
                  RadioListTile<RouteStopSort>(
                    title: Text(l10n.routeListSortDistance),
                    value: RouteStopSort.distance,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || picked == _sort) {
      return;
    }
    GeoOrigin? origin = _sortOrigin;
    if (picked == RouteStopSort.distance) {
      origin = await _currentOrigin();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _sort = picked;
      _sortOrigin = origin;
    });
  }

  Future<GeoOrigin?> _currentOrigin() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.routeListDistanceUnavailable)),
        );
      }
      return null;
    }
  }

  Future<void> _showFilterSheet(AppLocalizations l10n) async {
    var picked = _filter;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: RadioGroup<RouteStopStatusFilter>(
              groupValue: picked,
              onChanged: (v) {
                if (v != null) {
                  picked = v;
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.routeListFilterSheetTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeListFilterAll),
                    value: RouteStopStatusFilter.all,
                  ),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeStopStatusPending),
                    value: RouteStopStatusFilter.pending,
                  ),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeStopStatusArrived),
                    value: RouteStopStatusFilter.arrived,
                  ),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeStopStatusCompleted),
                    value: RouteStopStatusFilter.completed,
                  ),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeStopStatusFailed),
                    value: RouteStopStatusFilter.failed,
                  ),
                  RadioListTile<RouteStopStatusFilter>(
                    title: Text(l10n.routeStopStatusSkipped),
                    value: RouteStopStatusFilter.skipped,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!mounted || picked == _filter) {
      return;
    }
    setState(() => _filter = picked);
  }

  String _sortOptionLabel(AppLocalizations l10n) {
    return switch (_sort) {
      RouteStopSort.sequence => l10n.routeListSortSequence,
      RouteStopSort.eta => l10n.routeListSortEta,
      RouteStopSort.weight => l10n.routeListSortWeight,
      RouteStopSort.distance => l10n.routeListSortDistance,
    };
  }

  Widget _buildListToolbar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilter = _filter != RouteStopStatusFilter.all;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showSortSheet(l10n),
              icon: Icon(
                Icons.sort_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              label: Text(
                _sortOptionLabel(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showFilterSheet(l10n),
              icon: Badge(
                isLabelVisible: hasFilter,
                smallSize: 8,
                child: Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              label: Text(
                hasFilter
                    ? l10n.routeListFilterActive
                    : l10n.routeListFilterAll,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
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
                  final work = routeWorkStops(route.stops);
                  final completed = work
                      .where((s) => s.status == 'completed')
                      .length;
                  final visible = sortStops(
                    filterStops(route.stops, _filter),
                    _sort,
                    origin: _sortOrigin,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.routeStopsProgress(work.length, completed),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: work.isEmpty ? 0 : completed / work.length,
                              color: context.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                      _buildListToolbar(l10n),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<RouteBloc>().add(RouteLoadRequested());
                          },
                          child: visible.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(24),
                                  children: <Widget>[
                                    Text(
                                      l10n.routeListFilterEmpty,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  itemCount: visible.length,
                                  itemBuilder: (context, index) {
                                    return _StopCard(stop: visible[index]);
                                  },
                                ),
                        ),
                      ),
                    ],
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
    final l10n = context.l10n;
    final skipped = stop.status == 'skipped';
    final showMenu =
        canSkipRouteStop(stop.status) || canIncludeRouteStop(stop.status);
    return Opacity(
      opacity: skipped ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(child: Text('${stop.sequence}')),
          title: Text(
            stop.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(stop.customer.name),
              const SizedBox(height: 4),
              StopStatusChip(status: stop.status),
            ],
          ),
          isThreeLine: true,
          trailing: showMenu
              ? PopupMenuButton<_StopMenuAction>(
                  onSelected: (action) {
                    final bloc = context.read<RouteBloc>();
                    switch (action) {
                      case _StopMenuAction.skip:
                        bloc.add(RouteStopSkipped(stop.stopId));
                      case _StopMenuAction.include:
                        bloc.add(RouteStopIncluded(stop.stopId));
                    }
                  },
                  itemBuilder: (ctx) => <PopupMenuEntry<_StopMenuAction>>[
                    if (canSkipRouteStop(stop.status))
                      PopupMenuItem<_StopMenuAction>(
                        value: _StopMenuAction.skip,
                        child: Text(l10n.routeSkipStopLabel),
                      ),
                    if (canIncludeRouteStop(stop.status))
                      PopupMenuItem<_StopMenuAction>(
                        value: _StopMenuAction.include,
                        child: Text(l10n.routeIncludeStopLabel),
                      ),
                  ],
                )
              : null,
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
      ),
    );
  }
}

enum _StopMenuAction { skip, include }
