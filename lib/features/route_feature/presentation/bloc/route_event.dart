part of 'route_bloc.dart';

sealed class RouteEvent {}

final class RouteLoadRequested extends RouteEvent {
  RouteLoadRequested({this.rebuild = false});

  final bool rebuild;
}

final class RouteStopArrived extends RouteEvent {
  RouteStopArrived(this.stopId);
  final int stopId;
}

final class RouteStopCompleted extends RouteEvent {
  RouteStopCompleted(this.stopId);
  final int stopId;
}

final class RouteStopFailed extends RouteEvent {
  RouteStopFailed(this.stopId, {this.reason = ''});
  final int stopId;
  final String reason;
}
