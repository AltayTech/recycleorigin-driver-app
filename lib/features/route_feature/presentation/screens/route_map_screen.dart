import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recycleorigindriver/core/location/location_prominent_disclosure.dart';
import 'package:recycleorigindriver/core/location/location_tracking_service.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Full-screen map of today's depot, stops, and optional device location.
class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({
    super.key,
    required this.route,
    this.tracking,
    this.readDeviceLocation,
  });

  final DriverRoute route;

  /// Defaults to [LocationTrackingService.instance].
  final DriverLocationTracker? tracking;

  /// Defaults to a one-shot GPS read. Tests can inject a fake.
  final Future<LatLng?> Function()? readDeviceLocation;

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  static const LatLng _fallbackCenter = LatLng(41.0, 29.0);
  static const double _minZoom = 3;
  static const double _maxZoom = 19;

  final MapController _mapController = MapController();
  bool _mapReady = false;
  LatLng? _deviceLocation;

  List<LatLng> get _routePoints {
    return <LatLng>[
      LatLng(widget.route.depot.lat, widget.route.depot.lng),
      ...widget.route.stops.map((s) => LatLng(s.lat, s.lng)),
    ];
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openOsmCopyright() async {
    final uri = Uri.parse('https://www.openstreetmap.org/copyright');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _fitRoute() {
    if (!_mapReady) {
      return;
    }
    final points = _routePoints;
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(48),
        maxZoom: 16,
      ),
    );
  }

  void _zoomBy(double delta) {
    if (!_mapReady) {
      return;
    }
    final camera = _mapController.camera;
    final next = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(camera.center, next);
  }

  Future<void> _showMyLocation() async {
    final granted = await confirmLocationAccess(
      context: context,
      tracker: widget.tracking ?? LocationTrackingService.instance,
    );
    if (!granted || !mounted) {
      return;
    }
    try {
      final reader = widget.readDeviceLocation ?? _readGps;
      final here = await reader();
      if (!mounted || here == null) {
        if (mounted && here == null) {
          _showLocationUnavailable();
        }
        return;
      }
      setState(() => _deviceLocation = here);
      if (_mapReady) {
        _mapController.move(here, 15);
      }
    } on Exception {
      if (mounted) {
        _showLocationUnavailable();
      }
    }
  }

  Future<LatLng?> _readGps() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 8));
    return LatLng(pos.latitude, pos.longitude);
  }

  void _showLocationUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.routeMapLocationUnavailable)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final points = _routePoints;
    final center = points.isNotEmpty ? points.first : _fallbackCenter;
    final depot = LatLng(widget.route.depot.lat, widget.route.depot.lng);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeMapTitle)),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              onMapReady: () {
                setState(() => _mapReady = true);
                _fitRoute();
              },
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                maxNativeZoom: 19,
                userAgentPackageName: 'com.recycleorigin.recycleorigindriver',
              ),
              if (points.length >= 2)
                PolylineLayer(
                  polylines: <Polyline>[
                    Polyline(
                      points: points,
                      strokeWidth: 4,
                      color: context.brandPrimary,
                    ),
                  ],
                ),
              if (_deviceLocation != null)
                CircleLayer(
                  circles: <CircleMarker>[
                    CircleMarker(
                      point: _deviceLocation!,
                      radius: 18,
                      color: scheme.primary.withValues(alpha: 0.18),
                    ),
                    CircleMarker(
                      point: _deviceLocation!,
                      radius: 8,
                      color: scheme.primary,
                      borderStrokeWidth: 2,
                      borderColor: scheme.onPrimary,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: <Marker>[
                  Marker(
                    point: depot,
                    width: 40,
                    height: 40,
                    child: Tooltip(
                      message: l10n.routeMapDepotLabel,
                      child: CircleAvatar(
                        backgroundColor: scheme.tertiaryContainer,
                        foregroundColor: scheme.onTertiaryContainer,
                        child: const Icon(Icons.warehouse_outlined, size: 22),
                      ),
                    ),
                  ),
                  for (final stop in widget.route.stops)
                    Marker(
                      point: LatLng(stop.lat, stop.lng),
                      width: 36,
                      height: 36,
                      child: CircleAvatar(child: Text('${stop.sequence}')),
                    ),
                ],
              ),
              SimpleAttributionWidget(
                source: Text(
                  l10n.openStreetMapAttributionShort,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onTap: _openOsmCopyright,
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _MapToolColumn(
              onMyLocation: _showMyLocation,
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
              onFitRoute: _fitRoute,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapToolColumn extends StatelessWidget {
  const _MapToolColumn({
    required this.onMyLocation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitRoute,
  });

  final VoidCallback onMyLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MapToolButton(
            tooltip: l10n.mapScreenMyLocation,
            icon: Icons.my_location_rounded,
            onPressed: onMyLocation,
          ),
          _MapToolButton(
            tooltip: l10n.routeMapZoomIn,
            icon: Icons.add,
            onPressed: onZoomIn,
          ),
          _MapToolButton(
            tooltip: l10n.routeMapZoomOut,
            icon: Icons.remove,
            onPressed: onZoomOut,
          ),
          _MapToolButton(
            tooltip: l10n.routeMapFitRoute,
            icon: Icons.zoom_out_map_rounded,
            onPressed: onFitRoute,
          ),
        ],
      ),
    );
  }
}

class _MapToolButton extends StatelessWidget {
  const _MapToolButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: context.brandPrimary),
      onPressed: onPressed,
    );
  }
}
