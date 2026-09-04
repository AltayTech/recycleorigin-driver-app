import 'package:flutter/material.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';

class StopStatusChip extends StatelessWidget {
  const StopStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (Color color, IconData icon, String label) = switch (status) {
      'arrived' => (Colors.orange, Icons.place, l10n.routeStopStatusArrived),
      'completed' => (
        Colors.green,
        Icons.check_circle,
        l10n.routeStopStatusCompleted,
      ),
      'failed' => (Colors.red, Icons.error_outline, l10n.routeStopStatusFailed),
      'skipped' => (
        Colors.grey,
        Icons.remove_circle_outline,
        l10n.routeStopStatusSkipped,
      ),
      _ => (Colors.blueGrey, Icons.schedule, l10n.routeStopStatusPending),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
    );
  }
}
