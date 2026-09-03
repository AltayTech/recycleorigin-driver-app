/// Today's optimized driver route from GET /driver/route/today.
class DriverRoute {
  const DriverRoute({
    required this.routeId,
    required this.generatedAt,
    required this.algorithm,
    required this.depot,
    required this.stops,
  });

  factory DriverRoute.fromJson(Map<String, dynamic> json) {
    final stopsJson = json['stops'] as List<dynamic>? ?? [];
    final dynamic rawId = json['route_id'];
    final int routeId = rawId is num ? rawId.toInt() : 0;
    return DriverRoute(
      routeId: routeId,
      generatedAt:
          DateTime.tryParse(json['generated_at'] as String? ?? '') ??
          DateTime.now(),
      algorithm: json['algorithm'] as String? ?? '',
      depot: RouteDepot.fromJson(json['depot'] as Map<String, dynamic>? ?? {}),
      stops: stopsJson
          .map((e) => RouteStop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int routeId;
  final DateTime generatedAt;
  final String algorithm;
  final RouteDepot depot;
  final List<RouteStop> stops;
}

class RouteDepot {
  const RouteDepot({required this.lat, required this.lng, this.address});

  factory RouteDepot.fromJson(Map<String, dynamic> json) {
    return RouteDepot(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String?,
    );
  }

  final double lat;
  final double lng;
  final String? address;
}

class RouteStop {
  const RouteStop({
    required this.stopId,
    required this.sequence,
    required this.requestId,
    required this.customer,
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
    this.plannedArrival,
    this.plannedDeparture,
    this.items = const <String>[],
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    final cust = json['customer'] as Map<String, dynamic>? ?? {};
    final demand = json['demand'] as Map<String, dynamic>? ?? {};
    final itemsRaw = demand['items'] as List<dynamic>? ?? [];
    return RouteStop(
      stopId: (json['stop_id'] as num?)?.toInt() ?? 0,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      requestId: (json['request_id'] as num?)?.toInt() ?? 0,
      customer: RouteCustomer(
        name: cust['name'] as String? ?? '',
        phone: cust['phone'] as String? ?? '',
      ),
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      plannedArrival: _parse(json['planned_arrival'] as String?),
      plannedDeparture: _parse(json['planned_departure'] as String?),
      items: itemsRaw.map((e) => e.toString()).toList(),
    );
  }

  static DateTime? _parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  final int stopId;
  final int sequence;
  final int requestId;
  final RouteCustomer customer;
  final double lat;
  final double lng;
  final String address;
  final String status;
  final DateTime? plannedArrival;
  final DateTime? plannedDeparture;
  final List<String> items;
}

class RouteCustomer {
  const RouteCustomer({required this.name, required this.phone});

  final String name;
  final String phone;
}
