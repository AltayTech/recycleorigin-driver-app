import 'package:flutter/material.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/services/external_navigation_service.dart';

/// Bottom sheet to pick an external navigation app.
Future<void> showNavigationLauncherSheet(
  BuildContext context,
  RouteStop stop,
) async {
  final service = ExternalNavigationService();
  final targets = await service.availableTargets(
    lat: stop.lat,
    lng: stop.lng,
    label: stop.address,
  );
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Navigate to stop #${stop.sequence}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final t in targets)
              ListTile(
                leading: const Icon(Icons.navigation_outlined),
                title: Text(t.label),
                onTap: () async {
                  await service.launch(t);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
          ],
        ),
      );
    },
  );
}
