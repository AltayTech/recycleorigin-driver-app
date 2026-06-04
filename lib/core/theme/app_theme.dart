import 'package:flutter/material.dart';

import 'app_color_schemes.dart';

/// Legacy brand color accessors.
///
/// Prefer [Theme.of(context).colorScheme] and [DriverAppColors] for new UI.
/// These remain for gradual migration and brand-locked accents.
class AppTheme {
  static Color primary = AppColorSchemes.seed;

  static const Color secondary = Color(0xffE5E5E5);
  static const Color bg = Color(0xffF6F6F6);
  static const Color h1 = Color(0xff272727);
  static Color accent = const Color(0xffB2C243);
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color grey = Colors.grey;

  static Color appBarColor = primary;
  static const Color appBarIconColor = bg;

  static Color colorOne = Colors.red;
  static Color? colorTwo = Colors.red[300];
  static Color? colorThree = Colors.red[100];
  static Color iconColor1 = const Color(0xff6A4C93);

  static BoxDecoration listItemBox = BoxDecoration(
    borderRadius: BorderRadius.circular(5),
    border: Border.all(color: AppTheme.grey, width: 0.3),
  );

  /// Resolves a theme-aware list item border for [context].
  static BoxDecoration listItemDecoration(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: outline, width: 0.3),
    );
  }
}
