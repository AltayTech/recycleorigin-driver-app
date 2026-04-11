import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/utils/external_maps.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// OpenStreetMap preview of the customer's pickup coordinates ([flutter_map]),
/// with tap to open the device maps app.
class PickupLocationPreviewCard extends StatelessWidget {
  const PickupLocationPreviewCard({
    super.key,
    required this.latitude,
    required this.longitude,
    this.addressLine,
  });

  final String latitude;
  final String longitude;
  final String? addressLine;

  static bool hasValidCoordinates(String lat, String lng) {
    final (la, lo) = ExternalMaps.parseCoordinates(lat, lng);
    return la != null && lo != null;
  }

  Future<void> _openMaps(BuildContext context) async {
    final (lat, lng) = ExternalMaps.parseCoordinates(latitude, longitude);
    if (lat == null || lng == null) {
      return;
    }
    final ok = await ExternalMaps.openInExternalMaps(lat, lng);
    if (!context.mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.openMapsAppFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openOsmCopyright(BuildContext context) async {
    final uri = Uri.parse('https://www.openstreetmap.org/copyright');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (lat, lng) = ExternalMaps.parseCoordinates(latitude, longitude);
    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final point = LatLng(lat, lng);

    return Semantics(
      label: l10n.pickupMapPreviewSemantics,
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.map_rounded, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.pickupLocationMapTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openMaps(context),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 16,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          maxNativeZoom: 19,
                          tileProvider: CancellableNetworkTileProvider(
                            headers: {
                              'User-Agent':
                                  'flutter_map (com.recycleorigin.recycleorigindriver)',
                            },
                          ),
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: point,
                              width: 44,
                              height: 44,
                              alignment: Alignment.bottomCenter,
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 44,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        SimpleAttributionWidget(
                          source: Text(
                            l10n.openStreetMapAttributionShort,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () => _openOsmCopyright(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (addressLine != null && addressLine!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  addressLine!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: FilledButton.tonalIcon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.navigation_rounded, size: 20),
                label: Text(l10n.openInMapsAppLabel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
