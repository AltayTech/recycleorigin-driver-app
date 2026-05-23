import 'package:flutter/material.dart';

class StopStatusChip extends StatelessWidget {
  const StopStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (status) {
      'arrived' => (Colors.orange, Icons.place, 'Arrived'),
      'completed' => (Colors.green, Icons.check_circle, 'Done'),
      'failed' => (Colors.red, Icons.error_outline, 'Failed'),
      _ => (Colors.blueGrey, Icons.schedule, 'Pending'),
    };
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
    );
  }
}
