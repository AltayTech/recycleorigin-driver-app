import 'package:flutter/foundation.dart';

/// Tab indices for [NavigationBottomScreen] shell destinations.
abstract final class DriverShellTabIndex {
  static const int collection = 0;
  static const int warehouse = 1;
  static const int performance = 2;
  static const int wallet = 3;
  static const int profile = 4;
}

/// Pending shell tab switch requested from deep links (e.g. Help screen).
final ValueNotifier<int?> driverShellTabRequest = ValueNotifier<int?>(null);
