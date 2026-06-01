import 'package:flutter/material.dart';
import 'package:recycleorigindriver/features/performance_feature/presentation/screens/performance_screen.dart';

/// Legacy route — redirects to [PerformanceScreen].
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const routeName = '/StatisticsScreen';

  @override
  Widget build(BuildContext context) {
    return const PerformanceScreen();
  }
}
