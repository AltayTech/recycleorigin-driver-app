import 'package:recycleorigindriver/features/performance_feature/data/performance_models.dart';

enum PerformanceStatus { initial, loading, loaded, error }

class PerformanceState {
  const PerformanceState({
    this.status = PerformanceStatus.initial,
    this.range = '30d',
    this.performance,
    this.leaderboard,
    this.errorMessage,
  });

  final PerformanceStatus status;
  final String range;
  final PerformanceData? performance;
  final LeaderboardData? leaderboard;
  final String? errorMessage;

  PerformanceState copyWith({
    PerformanceStatus? status,
    String? range,
    PerformanceData? performance,
    LeaderboardData? leaderboard,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PerformanceState(
      status: status ?? this.status,
      range: range ?? this.range,
      performance: performance ?? this.performance,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
