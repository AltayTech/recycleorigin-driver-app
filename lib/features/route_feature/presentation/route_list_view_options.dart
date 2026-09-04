import 'package:latlong2/latlong.dart';

import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';

/// Client-side status filter for the My route list.
enum RouteStopStatusFilter { all, pending, arrived, completed, failed, skipped }

/// Client-side sort for the My route list. Does not change solver sequence.
enum RouteStopSort { sequence, eta, weight, distance }

/// GPS origin used when sorting by distance.
typedef GeoOrigin = ({double lat, double lng});

/// True when the stop is no longer work remaining on the route.
bool isInactiveRouteStopStatus(String status) {
  return status == 'completed' || status == 'failed' || status == 'skipped';
}

/// Stops that still count toward progress (skipped are excluded).
List<RouteStop> routeWorkStops(List<RouteStop> stops) {
  return stops
      .where((stop) => stop.status != 'skipped')
      .toList(growable: false);
}

/// Whether the driver may skip this stop.
bool canSkipRouteStop(String status) {
  return status == 'pending' || status == 'arrived';
}

/// Whether the driver may put a skipped stop back on the route.
bool canIncludeRouteStop(String status) => status == 'skipped';

/// Filters stops by status. [RouteStopStatusFilter.all] returns a copy.
List<RouteStop> filterStops(
  List<RouteStop> stops,
  RouteStopStatusFilter filter,
) {
  if (filter == RouteStopStatusFilter.all) {
    return List<RouteStop>.of(stops);
  }
  final slug = filter.name;
  return stops.where((stop) => stop.status == slug).toList();
}

/// Sorts a copy of [stops]. Distance falls back to sequence without [origin].
List<RouteStop> sortStops(
  List<RouteStop> stops,
  RouteStopSort sort, {
  GeoOrigin? origin,
}) {
  final out = List<RouteStop>.of(stops);
  switch (sort) {
    case RouteStopSort.sequence:
      out.sort((a, b) => a.sequence.compareTo(b.sequence));
    case RouteStopSort.eta:
      out.sort((a, b) {
        final at = a.plannedArrival;
        final bt = b.plannedArrival;
        if (at == null && bt == null) {
          return a.sequence.compareTo(b.sequence);
        }
        if (at == null) {
          return 1;
        }
        if (bt == null) {
          return -1;
        }
        final cmp = at.compareTo(bt);
        if (cmp != 0) {
          return cmp;
        }
        return a.sequence.compareTo(b.sequence);
      });
    case RouteStopSort.weight:
      out.sort((a, b) {
        final cmp = b.weightKg.compareTo(a.weightKg);
        if (cmp != 0) {
          return cmp;
        }
        return a.sequence.compareTo(b.sequence);
      });
    case RouteStopSort.distance:
      if (origin == null) {
        out.sort((a, b) => a.sequence.compareTo(b.sequence));
        break;
      }
      const distance = Distance();
      final from = LatLng(origin.lat, origin.lng);
      out.sort((a, b) {
        final da = distance.as(LengthUnit.Meter, from, LatLng(a.lat, a.lng));
        final db = distance.as(LengthUnit.Meter, from, LatLng(b.lat, b.lng));
        final cmp = da.compareTo(db);
        if (cmp != 0) {
          return cmp;
        }
        return a.sequence.compareTo(b.sequence);
      });
  }
  return out;
}
