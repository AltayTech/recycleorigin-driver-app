import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/route_feature/data/models/driver_route.dart';
import 'package:recycleorigindriver/features/route_feature/data/repositories/route_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc(this._repository) : super(const RouteState()) {
    on<RouteLoadRequested>(_onLoad);
    on<RouteStopArrived>(_onArrived);
    on<RouteStopCompleted>(_onCompleted);
    on<RouteStopFailed>(_onFailed);
  }

  final RouteRepository _repository;

  Future<void> _onLoad(
    RouteLoadRequested event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(status: RouteStatus.loading));
    final result = await _repository.fetchTodayRoute(
      rebuild: event.rebuild,
    );
    switch (result) {
      case Success(value: final payload):
        if (!payload.hasRoute) {
          emit(
            state.copyWith(
              status: RouteStatus.empty,
              route: null,
              hint: payload.emptyMessage,
              clearHint: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: RouteStatus.loaded,
              route: payload.route,
              clearHint: true,
            ),
          );
        }
      case Failure(message: final msg):
        emit(
          state.copyWith(
            status: RouteStatus.failure,
            message: msg,
            clearHint: true,
          ),
        );
    }
  }

  Future<void> _onArrived(
    RouteStopArrived event,
    Emitter<RouteState> emit,
  ) async {
    await _repository.markArrived(event.stopId);
    add(RouteLoadRequested());
  }

  Future<void> _onCompleted(
    RouteStopCompleted event,
    Emitter<RouteState> emit,
  ) async {
    await _repository.markCompleted(event.stopId);
    add(RouteLoadRequested());
  }

  Future<void> _onFailed(
    RouteStopFailed event,
    Emitter<RouteState> emit,
  ) async {
    await _repository.markFailed(event.stopId, reason: event.reason);
    add(RouteLoadRequested());
  }
}
