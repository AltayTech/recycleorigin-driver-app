import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls app [ThemeMode] and persists the user preference.
///
/// Uses a [ValueNotifier] so only the [MaterialApp] theme subtree rebuilds when
/// appearance changes.
class AppThemeController {
  static const String _prefsKeyThemeMode = 'app_theme_mode';

  /// Production default: follow the device light/dark setting.
  static const ThemeMode defaultThemeMode = ThemeMode.system;

  static final AppThemeController instance = AppThemeController._();

  AppThemeController._();

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(defaultThemeMode);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKeyThemeMode);
    themeModeNotifier.value = _resolveThemeMode(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == themeModeNotifier.value) {
      return;
    }
    themeModeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyThemeMode, _themeModeToStorage(mode));
  }

  ThemeMode _resolveThemeMode(String? stored) {
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return defaultThemeMode;
    }
  }

  String _themeModeToStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
