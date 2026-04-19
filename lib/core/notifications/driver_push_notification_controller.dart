import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/notifications/notification_deep_link.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// Registers FCM token with backend using `http` + [SecureStorage].
class DriverPushNotificationController {
  DriverPushNotificationController._();
  static final DriverPushNotificationController instance =
      DriverPushNotificationController._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  String? _lastToken;
  bool _listenersAttached = false;

  static const AndroidNotificationChannel _transactional =
      AndroidNotificationChannel(
    'transactional',
    'Transactional',
    description: 'Job and wallet updates.',
    importance: Importance.high,
  );

  Future<Map<String, String>> _headers() async {
    final t = await SecureStorage.getToken() ?? '';
    return <String, String>{
      'Authorization': 'Bearer $t',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> syncAfterLogin() async {
    if (kIsWeb) {
      return;
    }
    try {
      _messaging ??= FirebaseMessaging.instance;
      if (Platform.isIOS || Platform.isMacOS) {
        await _messaging!.requestPermission();
      } else if (Platform.isAndroid) {
        final st = await Permission.notification.status;
        if (!st.isGranted) {
          await Permission.notification.request();
        }
      }
      await _ensureLocal();
      final token = await _messaging!.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      if (token == _lastToken) {
        return;
      }
      final pkg = await PackageInfo.fromPlatform();
      final loc = AppLocaleController.instance.localeNotifier.value;
      final uri = Uri.parse('${Urls.rootUrl}/devices');
      final body = jsonEncode(<String, dynamic>{
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'app': 'driver',
        'locale': loc.languageCode,
        'app_version': pkg.version,
      });
      final res = await http.post(uri, headers: await _headers(), body: body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _lastToken = token;
      }
      if (!_listenersAttached) {
        _listenersAttached = true;
        _messaging!.onTokenRefresh.listen((t) async {
          _lastToken = null;
          final locNow =
              AppLocaleController.instance.localeNotifier.value;
          final pkgNow = await PackageInfo.fromPlatform();
          final b = jsonEncode(<String, dynamic>{
            'token': t,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'app': 'driver',
            'locale': locNow.languageCode,
            'app_version': pkgNow.version,
          });
          await http.post(uri, headers: await _headers(), body: b);
          _lastToken = t;
        });
        FirebaseMessaging.onMessage.listen(_showLocal);
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
          NotificationDeepLink.openFromData(
            m.data.map((k, v) => MapEntry(k, v)),
          );
        });
        final initial = await _messaging!.getInitialMessage();
        if (initial != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NotificationDeepLink.openFromData(
              initial.data.map((k, v) => MapEntry(k, v)),
            );
          });
        }
      }
    } catch (_) {}
  }

  Future<void> onLogout() async {
    final token = _lastToken;
    _lastToken = null;
    if (token == null || token.isEmpty) {
      return;
    }
    final uri = Uri.parse('${Urls.rootUrl}/devices').replace(
      queryParameters: <String, String>{'token': token},
    );
    await http.delete(uri, headers: await _headers());
  }

  Future<void> _ensureLocal() async {
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        final p = r.payload;
        if (p == null || p.isEmpty) {
          return;
        }
        try {
          final map = jsonDecode(p) as Map<String, dynamic>;
          NotificationDeepLink.openFromData(map);
        } catch (_) {}
      },
    );
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_transactional);
  }

  void _showLocal(RemoteMessage m) {
    final n = m.notification;
    final title = n?.title ?? m.data['title'] ?? 'Driver';
    final body = n?.body ?? m.data['body'] ?? '';
    const android = AndroidNotificationDetails(
      'transactional',
      'Transactional',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    _local.show(
      id: m.hashCode,
      title: title,
      body: body,
      notificationDetails:
          const NotificationDetails(android: android, iOS: ios),
      payload: jsonEncode(m.data),
    );
  }
}
