import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme_extensions.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/performance_feature/data/performance_models.dart';
import 'package:recycleorigindriver/features/performance_feature/data/performance_repository.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/bloc/performance_cubit.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/bloc/performance_state.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver performance dashboard with gamification.
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key, this.embedInShell = false});

  static const routeName = '/performanceScreen';

  /// When true, rendered inside [NavigationBottomScreen] (no own app bar).
  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PerformanceCubit(PerformanceRepository())..load(),
      child: _PerformanceView(embedInShell: embedInShell),
    );
  }
}

class _PerformanceView extends StatelessWidget {
  const _PerformanceView({required this.embedInShell});

  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = BlocBuilder<PerformanceCubit, PerformanceState>(
      builder: (context, state) {
        if (state.status == PerformanceStatus.loading &&
            state.performance == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PerformanceStatus.error &&
            state.performance == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? l10n.performanceLoadError),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<PerformanceCubit>().load(),
                    child: Text(l10n.retryLabel),
                  ),
                ],
              ),
            ),
          );
        }
        final data = state.performance;
        if (data == null) {
          return const SizedBox.shrink();
        }
        return RefreshIndicator(
          onRefresh: () => context.read<PerformanceCubit>().load(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              embedInShell ? 8 : 16,
              16,
              embedInShell ? 24 : 80,
            ),
            children: [
              if (embedInShell) _RangeToolbar(),
              _PerformanceHero(metrics: data.impact),
              const SizedBox(height: 12),
              _LevelCard(level: data.level),
              const SizedBox(height: 12),
              if (data.impact.averageRating != null)
                _RatingChip(rating: data.impact.averageRating!),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StreakCard(streak: data.streak)),
                  const SizedBox(width: 8),
                  Expanded(child: _GoalCard(goal: data.goal)),
                ],
              ),
              const SizedBox(height: 12),
              _TrendChart(series: data.series),
              const SizedBox(height: 12),
              _BadgesGrid(badges: data.badges),
              const SizedBox(height: 12),
              _LeaderboardCard(rank: data.rank, leaderboard: state.leaderboard),
            ],
          ),
        );
      },
    );

    if (embedInShell) {
      return ColoredBox(color: context.pageBackground, child: body);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(l10n.performanceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<PerformanceCubit>().load(),
          ),
        ],
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: body,
    );
  }
}

class _RangeToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlocBuilder<PerformanceCubit, PerformanceState>(
            buildWhen: (a, b) => a.range != b.range,
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.date_range_outlined),
                initialValue: state.range,
                onSelected: context.read<PerformanceCubit>().setRange,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: '7d',
                    child: Text(l10n.performanceRange7d),
                  ),
                  PopupMenuItem(
                    value: '30d',
                    child: Text(l10n.performanceRange30d),
                  ),
                  PopupMenuItem(
                    value: '90d',
                    child: Text(l10n.performanceRange90d),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<PerformanceCubit>().load(),
          ),
        ],
      ),
    );
  }
}

class _PerformanceHero extends StatelessWidget {
  const _PerformanceHero({required this.metrics});

  final PerformanceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [context.brandPrimary, context.driverColors.heroGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: context.brandPrimary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.performanceHeroTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(
                l10n.performancePickupsLabel,
                '${metrics.completedPickups}',
                metrics.pickupsTrend,
              ),
              _Stat(
                l10n.performanceWeightLabel,
                '${metrics.recycledWeightKg.toStringAsFixed(1)} kg',
                metrics.weightTrend,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.performanceEarningsLabel}: ${metrics.earnings} ${metrics.currency}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, [this.trend]);

  final String label;
  final String value;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trend != null && trend!.isNotEmpty)
            Text(
              trend!,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level});

  final LevelInfo level;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: level.progress.clamp(0, 1),
                    color: context.brandPrimary,
                  ),
                  Text(
                    '${level.tier}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.tierName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(l10n.performanceXpLabel(level.xp, level.xpToNext)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star_rounded, color: Colors.amber),
        title: Text(context.l10n.ratingLabel),
        trailing: Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_fire_department,
              color: streak.active ? Colors.orange : Colors.grey,
            ),
            Text(l10n.performanceStreakTitle),
            Text(
              l10n.performanceStreakValue(streak.current, streak.longest),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final GoalInfo goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.performanceGoalTitle),
            Text(
              '${goal.current.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: goal.progress.clamp(0, 1)),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.series});

  final PerformanceSeries series;

  @override
  Widget build(BuildContext context) {
    final spots = series.pickupPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
        .toList();
    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }
    final maxY = spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.performanceTrendTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                      ),
                    ),
                    bottomTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                  ),
                  minY: 0,
                  maxY: maxY < 1 ? 1 : maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: context.brandPrimary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: context.brandPrimary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.badges});

  final List<BadgeInfo> badges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.performanceBadgesTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges
              .map(
                (b) => Opacity(
                  opacity: b.earned ? 1 : 0.5,
                  child: Chip(
                    avatar: Icon(
                      b.earned ? Icons.check_circle : Icons.lock_outline,
                      size: 18,
                    ),
                    label: Text(b.name),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.rank, this.leaderboard});

  final RankSummary rank;
  final LeaderboardData? leaderboard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = leaderboard?.entries ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceLeaderboardTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (rank.position > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.performanceRankSummary(
                    rank.position,
                    rank.totalParticipants,
                    rank.percentile,
                  ),
                ),
              ),
            ...entries.map(
              (e) => ListTile(
                dense: true,
                leading: CircleAvatar(child: Text('${e.rank}')),
                title: Text(e.displayName),
                trailing: Text(e.score.toStringAsFixed(0)),
                tileColor: e.isSelf
                    ? context.brandPrimary.withValues(alpha: 0.1)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
