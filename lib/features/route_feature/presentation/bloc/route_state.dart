part of 'route_bloc.dart';

enum RouteStatus { initial, loading, loaded, empty, failure }

class RouteState {
  const RouteState({
    this.status = RouteStatus.initial,
    this.route,
    this.message,
    this.hint,
    this.busyStopId,
    this.actionError,
  });

  final RouteStatus status;
  final DriverRoute? route;
  final String? message;
  final String? hint;

  /// Stop currently being updated (arrived / complete / fail / skip).
  final int? busyStopId;

  /// User-facing error from the last stop mutation.
  final String? actionError;

  bool get isStopActionBusy => busyStopId != null;

  RouteState copyWith({
    RouteStatus? status,
    DriverRoute? route,
    String? message,
    String? hint,
    bool clearHint = false,
    int? busyStopId,
    bool clearBusy = false,
    String? actionError,
    bool clearActionError = false,
  }) {
    return RouteState(
      status: status ?? this.status,
      route: route ?? this.route,
      message: message ?? this.message,
      hint: clearHint ? null : (hint ?? this.hint),
      busyStopId: clearBusy ? null : (busyStopId ?? this.busyStopId),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}
