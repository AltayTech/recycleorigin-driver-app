import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recycleorigindriver/core/network/auth_http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/notifications/notification_deep_link.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// Registers this installation for push (Firebase Installation ID) with the
/// backend using `http` + [SecureStorage].
class DriverPushNotificationController {
  DriverPushNotificationController._();
  static final DriverPushNotificationController instance =
      DriverPushNotificationController._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  String? _lastFid;
  bool _loggedIn = false;
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
      if (!_listenersAttached) {
        _listenersAttached = true;
        // Subscribe before register() so the first FID is not missed. The
        // stream fires after every completed registration, including when
        // Firebase rotates the installation ID.
        _messaging!.onRegistered.listen(_onFidRegistered);
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
      _loggedIn = true;
      await _messaging!.register();
    } catch (_) {}
  }

  /// Sends the Firebase Installation ID (FID) from
  /// [FirebaseMessaging.onRegistered] to the backend as this device's push
  /// target.
  Future<void> _onFidRegistered(String fid) async {
    if (!_loggedIn || fid.isEmpty || fid == _lastFid) {
      return;
    }
    try {
      final pkg = await PackageInfo.fromPlatform();
      final loc = AppLocaleController.instance.localeNotifier.value;
      final res = await http.post(
        Uri.parse('${Urls.rootUrl}/devices'),
        headers: await _headers(),
        body: jsonEncode(<String, dynamic>{
          'token': fid,
          'kind': 'fid',
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app': 'driver',
          'locale': loc.languageCode,
          'app_version': pkg.version,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _lastFid = fid;
      }
    } catch (_) {}
  }

  Future<void> onLogout() async {
    final fid = _lastFid;
    _lastFid = null;
    _loggedIn = false;
    if (fid == null || fid.isEmpty) {
      return;
    }
    final uri = Uri.parse('${Urls.rootUrl}/devices')
        .replace(queryParameters: <String, String>{'token': fid});
    await http.delete(uri, headers: await _headers());
    try {
      // Stop FCM delivering to this installation until the next login calls
      // register() again.
      await _messaging?.unregister();
    } catch (_) {}
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
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
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
      notificationDetails: const NotificationDetails(
        android: android,
        iOS: ios,
      ),
      payload: jsonEncode(m.data),
    );
  }
}
