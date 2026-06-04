import 'package:flutter/material.dart';

/// Brand and semantic color definitions for light and dark [ColorScheme]s.
abstract final class AppColorSchemes {
  /// RecycleOrigin driver brand green.
  static const Color seed = Color(0xFF77C243);

  static const Color _bodyTextLight = Color.fromRGBO(20, 51, 51, 1);

  static ColorScheme light() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: seed,
      surface: const Color(0xFFFFFFFF),
      surfaceContainerLowest: const Color(0xFFF6F6F6),
    );
  }

  static ColorScheme dark() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: seed,
      surface: const Color(0xFF1C1C1E),
      surfaceContainerLowest: const Color(0xFF121214),
    );
  }

  /// App bar foreground on brand primary (light gray in light mode).
  static Color appBarOnPrimary(ColorScheme scheme) {
    return scheme.brightness == Brightness.light
        ? scheme.surfaceContainerLowest
        : scheme.onPrimary;
  }

  /// Primary body text tint used in light mode typography.
  static Color? bodyTextOverride(ColorScheme scheme) {
    return scheme.brightness == Brightness.light ? _bodyTextLight : null;
  }
}
