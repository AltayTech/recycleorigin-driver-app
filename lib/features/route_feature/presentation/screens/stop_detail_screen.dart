import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/navigation_launcher_sheet.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({super.key, required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeStopTitle(stop.sequence))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          StopStatusChip(status: stop.status),
          const SizedBox(height: 16),
          Text(stop.address, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(stop.customer.name),
          if (stop.customer.phone.isNotEmpty)
            TextButton.icon(
              onPressed: () =>
                  launchUrl(Uri.parse('tel:${stop.customer.phone}')),
              icon: const Icon(Icons.phone),
              label: Text(stop.customer.phone),
            ),
          if (stop.plannedArrival != null)
            Text(l10n.routeStopEta(stop.plannedArrival!.toLocal().toString())),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => showNavigationLauncherSheet(context, stop),
            icon: const Icon(Icons.navigation),
            label: Text(l10n.routeNavigateButton),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopArrived(stop.stopId),
                ),
                child: Text(l10n.routeArrivedButton),
              ),
              FilledButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopCompleted(stop.stopId),
                ),
                child: Text(l10n.routeCompletedButton),
              ),
              TextButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopFailed(stop.stopId, reason: 'unable'),
                ),
                child: Text(l10n.routeFailedButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
