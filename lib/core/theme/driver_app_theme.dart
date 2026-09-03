import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color_schemes.dart';
import 'app_theme_extensions.dart';

/// Centralized light and dark [ThemeData] for the driver app.
abstract final class DriverAppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = brightness == Brightness.light
        ? AppColorSchemes.light()
        : AppColorSchemes.dark();
    final tokens = brightness == Brightness.light
        ? DriverAppColors.light(scheme)
        : DriverAppColors.dark(scheme);

    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    final baseText = base.textTheme;
    final bodyOverride = AppColorSchemes.bodyTextOverride(scheme);
    final textTheme = baseText.copyWith(
      bodyLarge: baseText.bodyLarge?.copyWith(color: bodyOverride),
      bodyMedium: baseText.bodyMedium?.copyWith(color: bodyOverride),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: baseText.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
    );

    final appBarTheme = AppBarTheme(
      backgroundColor: tokens.appBarBackground,
      foregroundColor: tokens.appBarForeground,
      iconTheme: IconThemeData(color: tokens.appBarForeground),
      actionsIconTheme: IconThemeData(color: tokens.appBarForeground),
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: tokens.appBarForeground,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: brightness == Brightness.light ? 2 : 1,
        shadowColor: scheme.shadow.withValues(
          alpha: brightness == Brightness.light ? 0.12 : 0.35,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.55),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            size: selected ? 26 : 24,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
    );
  }
}
