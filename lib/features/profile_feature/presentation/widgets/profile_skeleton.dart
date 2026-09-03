import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

/// Loading placeholder for the profile tab.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.pageBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          const _SkeletonBox(height: 200, borderRadius: 0),
          Transform.translate(
            offset: const Offset(0, -28),
            child: const _SkeletonBox(height: 88, borderRadius: 16),
          ),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 18, width: 100),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 120, borderRadius: 12),
          const SizedBox(height: 16),
          const _SkeletonBox(height: 18, width: 100),
          const SizedBox(height: 8),
          const _SkeletonBox(height: 200, borderRadius: 12),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width, this.borderRadius = 8});

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
