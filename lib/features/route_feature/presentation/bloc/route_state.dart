part of 'route_bloc.dart';

enum RouteStatus { initial, loading, loaded, empty, failure }

class RouteState {
  const RouteState({
    this.status = RouteStatus.initial,
    this.route,
    this.message,
    this.hint,
  });

  final RouteStatus status;
  final DriverRoute? route;
  final String? message;
  final String? hint;

  RouteState copyWith({
    RouteStatus? status,
    DriverRoute? route,
    String? message,
    String? hint,
    bool clearHint = false,
  }) {
    return RouteState(
      status: status ?? this.status,
      route: route ?? this.route,
      message: message ?? this.message,
      hint: clearHint ? null : (hint ?? this.hint),
    );
  }
}
