import 'package:flutter/material.dart';

/// Read-only stars (1–5), supports half-star from [value].
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.value,
    this.size = 20,
    this.color,
  });

  final double value;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        final fill = (value - i).clamp(0.0, 1.0);
        final IconData icon = fill >= 1
            ? Icons.star_rounded
            : fill > 0
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: c);
      }),
    );
  }
}

/// Tappable 1–5 star selector.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
    this.color,
    this.emptyColor,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final Color? color;
  final Color? emptyColor;

  @override
  Widget build(BuildContext context) {
    final filled = color ?? Theme.of(context).colorScheme.primary;
    final empty = emptyColor ?? Colors.grey.shade400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        final star = i + 1;
        final isOn = star <= value;
        return InkWell(
          onTap: () => onChanged(star),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Icon(
              isOn ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: isOn ? filled : empty,
            ),
          ),
        );
      }),
    );
  }
}
