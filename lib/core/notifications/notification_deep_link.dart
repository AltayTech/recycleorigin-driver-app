import 'package:recycleorigindriver/core/navigation/app_navigator.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_detail_screen.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/screens/collect_list_screen.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_screen.dart';
import 'package:recycleorigindriver/features/wallet_feature/presentation/wallet_screen.dart';

class NotificationDeepLink {
  NotificationDeepLink._();

  static void openFromData(Map<String, dynamic> data) {
    final nav = appNavigatorKey.currentState;
    if (nav == null) {
      return;
    }
    final deep = data['deep_link'] as String? ?? '';
    if (deep.startsWith('/driver/collects/')) {
      final id = int.tryParse(deep.split('/').last);
      if (id != null) {
        nav.pushNamed(CollectDetailScreen.routeName, arguments: id);
      }
      return;
    }
    if (deep == '/wallet' || deep.startsWith('/wallet')) {
      nav.pushNamed(WalletScreen.routeName);
      return;
    }
    final t = data['type'] as String? ?? '';
    if (t.startsWith('driver.') || t.startsWith('collect.')) {
      nav.pushNamed(CollectListScreen.routeName);
      return;
    }
    nav.pushNamed(DriverNotificationScreen.routeName);
  }
}
