import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key, required this.route});

  final DriverRoute route;

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[
      LatLng(route.depot.lat, route.depot.lng),
      ...route.stops.map((s) => LatLng(s.lat, s.lng)),
    ];
    final center =
        points.isNotEmpty ? points.first : const LatLng(41.0, 29.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Route map')),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 12),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.recycleorigin.driver',
          ),
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(points: points, strokeWidth: 4, color: Colors.blue),
            ],
          ),
          MarkerLayer(
            markers: <Marker>[
              for (var i = 0; i < route.stops.length; i++)
                Marker(
                  point: LatLng(route.stops[i].lat, route.stops[i].lng),
                  width: 36,
                  height: 36,
                  child: CircleAvatar(
                    child: Text('${route.stops[i].sequence}'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
