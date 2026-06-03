import 'package:flutter/material.dart';

/// Standard elevated card surface for list items and sections.
class ThemedSurfaceCard extends StatelessWidget {
  const ThemedSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isLight ? 0.06 : 0.35),
            blurRadius: isLight ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
