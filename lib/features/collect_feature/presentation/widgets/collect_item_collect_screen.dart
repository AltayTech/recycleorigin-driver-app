import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/utils/external_maps.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/widgets/pickup_location_preview_card.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';

class CollectItemCollectsScreen extends StatelessWidget {
  const CollectItemCollectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collect =
        Provider.of<RequestWasteItem>(context, listen: false);
    final l10n = context.l10n;
    final (statusColor, statusIcon) =
        _statusVisuals(collect.requestStatusKey);
    final statusText = collect.requestStatusDisplay(l10n);

    final estWeight =
        double.tryParse(collect.total_collects_weight.estimated) ?? 0;
    final estPrice =
        double.tryParse(collect.total_collects_price.estimated) ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pushNamed(
        CollectDetailScreen.routeName,
        arguments: collect.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (PickupLocationPreviewCard.hasValidCoordinates(
                  collect.address_data.latitude,
                  collect.address_data.longitude,
                ))
                  IconButton(
                    tooltip: l10n.openInMapsAppLabel,
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      final (lat, lng) = ExternalMaps.parseCoordinates(
                        collect.address_data.latitude,
                        collect.address_data.longitude,
                      );
                      if (lat == null || lng == null) {
                        return;
                      }
                      final ok =
                          await ExternalMaps.openInExternalMaps(lat, lng);
                      if (!context.mounted) {
                        return;
                      }
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.openMapsAppFailed),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.map_rounded,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  text: EnArConvertor.localize(
                    context,
                    collect.collect_date.day,
                  ),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.access_time,
                  text: EnArConvertor.localize(
                    context,
                    collect.collect_date.time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatBadge(
                    label: l10n.totalEstimatedWeightLabel,
                    value:
                        '${EnArConvertor.localize(context, estWeight.toStringAsFixed(1))} ${l10n.kilogramLabel}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBadge(
                    label: l10n.tomanLabel,
                    value: EnArConvertor.localize(
                      context,
                      _fmtPrice(estPrice),
                    ),
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            if (collect.address_data.address.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      collect.address_data.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtPrice(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  (Color, IconData) _statusVisuals(String key) {
    return switch (key) {
      'pending_assignment' =>
        (Colors.grey, Icons.person_search_rounded),
      'pending_driver_acceptance' =>
        (Colors.orange, Icons.hourglass_top_rounded),
      'driver_accepted' || 'in_progress' =>
        (AppTheme.primary, Icons.how_to_reg_rounded),
      'picked_up' =>
        (Colors.indigo, Icons.inventory_2_rounded),
      'collected' =>
        (Colors.green, Icons.check_circle_rounded),
      'cancelled' =>
        (Colors.red.shade400, Icons.cancel_rounded),
      _ => (AppTheme.accent, Icons.drive_eta),
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
