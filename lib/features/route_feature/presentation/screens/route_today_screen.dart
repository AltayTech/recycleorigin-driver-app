import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/network/api_provider.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/bloc/route_bloc.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/route_map_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/screens/stop_detail_screen.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/widgets/stop_status_chip.dart';

/// Ordered list of today's route stops.
class RouteTodayScreen extends StatelessWidget {
  const RouteTodayScreen({super.key});

  static const routeName = '/route/today';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteBloc(RouteRepository(ApiProvider.client))
        ..add(RouteLoadRequested()),
      child: const _RouteTodayView(),
    );
  }
}

class _RouteTodayView extends StatelessWidget {
  const _RouteTodayView();

  @override
  Widget build(BuildContext context) {
    final isDev = AppConfig.environment == 'development' || kDebugMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My route'),
        actions: <Widget>[
          if (isDev)
            IconButton(
              tooltip: 'Rebuild route from assigned collects',
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
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state.status == RouteStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == RouteStatus.failure) {
            return _MessagePanel(
              icon: Icons.error_outline,
              title: 'Could not load route',
              body: state.message ?? 'Unknown error',
              action: FilledButton(
                onPressed: () =>
                    context.read<RouteBloc>().add(RouteLoadRequested()),
                child: const Text('Retry'),
              ),
            );
          }
          if (state.status == RouteStatus.empty || state.route == null) {
            return _MessagePanel(
              icon: Icons.route_outlined,
              title: 'No route yet',
              body: state.hint ??
                  'Assign collection requests to your driver account, '
                  'then enable routing in the admin panel.',
              action: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FilledButton(
                    onPressed: () =>
                        context.read<RouteBloc>().add(RouteLoadRequested()),
                    child: const Text('Refresh'),
                  ),
                  if (isDev) ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.read<RouteBloc>().add(
                            RouteLoadRequested(rebuild: true),
                          ),
                      child: const Text('Rebuild route (dev)'),
                    ),
                  ],
                ],
              ),
            );
          }
          final route = state.route!;
          final completed =
              route.stops.where((s) => s.status == 'completed').length;
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
                          '${route.stops.length} stops · $completed done',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: route.stops.isEmpty
                              ? 0
                              : completed / route.stops.length,
                          color: AppTheme.primary,
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
            Icon(icon, size: 48, color: AppTheme.grey),
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
