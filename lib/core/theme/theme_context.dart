import 'package:flutter/material.dart';

/// Theme-aware color helpers for migrating off static [AppTheme] constants.
extension DriverThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Scaffold / page background.
  Color get pageBackground => colors.surfaceContainerLowest;

  /// Primary text on surfaces.
  Color get primaryText => colors.onSurface;

  /// Secondary / caption text.
  Color get secondaryText => colors.onSurfaceVariant;

  /// Card and elevated surface fill.
  Color get cardSurface => colors.surface;

  /// Brand primary (actions, indicators).
  Color get brandPrimary => colors.primary;
}
