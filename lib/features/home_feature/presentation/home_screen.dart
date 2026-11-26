import 'package:material_ui/material_ui.dart';

import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';

/// Backwards-compatible route; the driver shell is [NavigationBottomScreen].
class HomeScreen extends StatelessWidget {
  static const routeName = '/HomeScreen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const NavigationBottomScreen();
}
