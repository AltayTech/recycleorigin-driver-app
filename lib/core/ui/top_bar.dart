import 'package:flutter/material.dart';

import 'curve_painter.dart';

/// Curved header used on profile and similar screens.
///
/// [height] scales with parent constraints so the header fits inside tab
/// bodies and smaller viewports without forcing full-screen [MediaQuery]
/// sizes.
class TopBar extends StatelessWidget {
  const TopBar({super.key, this.height = 200});

  /// Paint height; callers should clamp from [LayoutBuilder] when needed.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: CurvePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}
