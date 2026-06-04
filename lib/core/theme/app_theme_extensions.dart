import 'package:flutter/material.dart';

import 'app_color_schemes.dart';

/// Design tokens not covered by [ColorScheme] (gradients, list borders).
@immutable
class DriverAppColors extends ThemeExtension<DriverAppColors> {
  const DriverAppColors({
    required this.heroGradientEnd,
    required this.listItemBorder,
    required this.appBarBackground,
    required this.appBarForeground,
  });

  final Color heroGradientEnd;
  final Color listItemBorder;
  final Color appBarBackground;
  final Color appBarForeground;

  static DriverAppColors light(ColorScheme scheme) {
    return DriverAppColors(
      heroGradientEnd: const Color(0xFF1F8B61),
      listItemBorder: scheme.outlineVariant,
      appBarBackground: scheme.primary,
      appBarForeground: AppColorSchemes.appBarOnPrimary(scheme),
    );
  }

  static DriverAppColors dark(ColorScheme scheme) {
    return DriverAppColors(
      heroGradientEnd: const Color(0xFF2A9B6E),
      listItemBorder: scheme.outlineVariant,
      appBarBackground: scheme.primary,
      appBarForeground: AppColorSchemes.appBarOnPrimary(scheme),
    );
  }

  @override
  DriverAppColors copyWith({
    Color? heroGradientEnd,
    Color? listItemBorder,
    Color? appBarBackground,
    Color? appBarForeground,
  }) {
    return DriverAppColors(
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      listItemBorder: listItemBorder ?? this.listItemBorder,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarForeground: appBarForeground ?? this.appBarForeground,
    );
  }

  @override
  DriverAppColors lerp(ThemeExtension<DriverAppColors>? other, double t) {
    if (other is! DriverAppColors) {
      return this;
    }
    return DriverAppColors(
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      listItemBorder: Color.lerp(listItemBorder, other.listItemBorder, t)!,
      appBarBackground:
          Color.lerp(appBarBackground, other.appBarBackground, t)!,
      appBarForeground:
          Color.lerp(appBarForeground, other.appBarForeground, t)!,
    );
  }
}

/// Convenience accessors for [DriverAppColors] on [BuildContext].
extension DriverAppColorsContext on BuildContext {
  DriverAppColors get driverColors =>
      Theme.of(this).extension<DriverAppColors>()!;
}
