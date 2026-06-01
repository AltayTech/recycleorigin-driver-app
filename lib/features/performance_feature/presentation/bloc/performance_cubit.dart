import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/utils/result.dart';
import 'package:recycleorigindriver/features/performance_feature/data/performance_models.dart';
import 'package:recycleorigindriver/features/performance_feature/data/performance_repository.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/bloc/performance_state.dart';

/// Loads driver performance and gamification data.
class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit(this._repository) : super(const PerformanceState());

  final PerformanceRepository _repository;

  Future<void> load({String? range}) async {
    final selectedRange = range ?? state.range;
    emit(state.copyWith(
      status: PerformanceStatus.loading,
      range: selectedRange,
      clearError: true,
    ));

    final perfResult = await _repository.fetchPerformance(range: selectedRange);
    final boardResult = await _repository.fetchLeaderboard(
      range: selectedRange,
    );

    switch (perfResult) {
      case Success(:final value):
        LeaderboardData? board;
        if (boardResult case Success(value: final b)) {
          board = b;
        }
        emit(state.copyWith(
          status: PerformanceStatus.loaded,
          performance: value,
          leaderboard: board,
          clearError: true,
        ));
      case Failure(:final message):
        emit(state.copyWith(
          status: PerformanceStatus.error,
          errorMessage: message,
        ));
    }
  }

  Future<void> setRange(String range) => load(range: range);
}
