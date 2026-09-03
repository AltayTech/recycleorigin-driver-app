import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/navigation_launcher_sheet.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';

class StopDetailScreen extends StatelessWidget {
  const StopDetailScreen({super.key, required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stop #${stop.sequence}')),
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
            Text('ETA: ${stop.plannedArrival!.toLocal()}'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => showNavigationLauncherSheet(context, stop),
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopArrived(stop.stopId),
                ),
                child: const Text('Arrived'),
              ),
              FilledButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopCompleted(stop.stopId),
                ),
                child: const Text('Completed'),
              ),
              TextButton(
                onPressed: () => context.read<RouteBloc>().add(
                  RouteStopFailed(stop.stopId, reason: 'unable'),
                ),
                child: const Text('Failed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
