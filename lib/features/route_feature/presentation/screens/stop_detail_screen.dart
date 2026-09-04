import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/route_list_view_options.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/navigation_launcher_sheet.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({super.key, required this.stop});

  final RouteStop stop;

  RouteStop _currentStop(RouteState state) {
    final stops = state.route?.stops;
    if (stops == null) {
      return stop;
    }
    for (final s in stops) {
      if (s.stopId == stop.stopId) {
        return s;
      }
    }
    return stop;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        final current = _currentStop(state);
        final skipped = canIncludeRouteStop(current.status);
        final terminal =
            current.status == 'completed' || current.status == 'failed';
        return Scaffold(
          appBar: AppBar(title: Text(l10n.routeStopTitle(current.sequence))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              StopStatusChip(status: current.status),
              const SizedBox(height: 16),
              Text(
                current.address,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(current.customer.name),
              if (current.customer.phone.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      launchUrl(Uri.parse('tel:${current.customer.phone}')),
                  icon: const Icon(Icons.phone),
                  label: Text(current.customer.phone),
                ),
              if (current.plannedArrival != null)
                Text(
                  l10n.routeStopEta(
                    current.plannedArrival!.toLocal().toString(),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => showNavigationLauncherSheet(context, current),
                icon: const Icon(Icons.navigation),
                label: Text(l10n.routeNavigateButton),
              ),
              const SizedBox(height: 12),
              if (!terminal)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (canSkipRouteStop(current.status))
                      OutlinedButton(
                        onPressed: () => context.read<RouteBloc>().add(
                          RouteStopSkipped(current.stopId),
                        ),
                        child: Text(l10n.routeSkipStopLabel),
                      ),
                    if (skipped)
                      FilledButton(
                        onPressed: () => context.read<RouteBloc>().add(
                          RouteStopIncluded(current.stopId),
                        ),
                        child: Text(l10n.routeIncludeStopLabel),
                      ),
                    if (!skipped) ...<Widget>[
                      OutlinedButton(
                        onPressed: () => context.read<RouteBloc>().add(
                          RouteStopArrived(current.stopId),
                        ),
                        child: Text(l10n.routeArrivedButton),
                      ),
                      FilledButton(
                        onPressed: () => context.read<RouteBloc>().add(
                          RouteStopCompleted(current.stopId),
                        ),
                        child: Text(l10n.routeCompletedButton),
                      ),
                      TextButton(
                        onPressed: () => context.read<RouteBloc>().add(
                          RouteStopFailed(current.stopId, reason: 'unable'),
                        ),
                        child: Text(l10n.routeFailedButton),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
