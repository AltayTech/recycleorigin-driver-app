import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/theme/theme_context.dart';

class ButtonBottom extends StatelessWidget {
  const ButtonBottom({super.key, 
    required this.width,
    required this.height,
    required this.text,
    this.isActive = false,
  });

  final double width;
  final double height;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? context.brandPrimary : scheme.onSurfaceVariant,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          text,
          textScaler: textScaler,
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
