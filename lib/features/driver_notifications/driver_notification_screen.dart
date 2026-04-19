import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/notifications/notification_deep_link.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_models.dart';
import 'package:recycleorigindriver/features/driver_notifications/driver_notification_preferences_screen.dart';

class DriverNotificationScreen extends StatefulWidget {
  static const routeName = '/driverNotifications';

  const DriverNotificationScreen({super.key});

  @override
  State<DriverNotificationScreen> createState() =>
      _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends State<DriverNotificationScreen> {
  final List<DriverNotificationItem> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<Map<String, String>> _headers() async {
    final t = await SecureStorage.getToken() ?? '';
    return <String, String>{
      'Authorization': 'Bearer $t',
      'Accept': 'application/json',
    };
  }

  Future<void> _load() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final uri = Uri.parse('${Urls.rootUrl}/notifications')
        .replace(queryParameters: <String, String>{'page': '1', 'limit': '50'});
    final res = await http.get(uri, headers: await _headers());
    if (!mounted) {
      return;
    }
    if (res.statusCode != 200) {
      setState(() {
        _loading = false;
        _error = 'Failed (${res.statusCode})';
      });
      return;
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final raw = body['items'] as List<dynamic>? ?? [];
    setState(() {
      _items
        ..clear()
        ..addAll(
          raw.map(
            (e) => DriverNotificationItem.fromJson(e as Map<String, dynamic>),
          ),
        );
      _loading = false;
    });
  }

  Future<void> _markRead(DriverNotificationItem it) async {
    if (it.isRead) {
      return;
    }
    final uri =
        Uri.parse('${Urls.rootUrl}/notifications/${it.id}/read');
    await http.post(uri, headers: await _headers());
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(
              DriverNotificationPreferencesScreen.routeName,
            ),
          ),
          TextButton(
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final uri =
                        Uri.parse('${Urls.rootUrl}/notifications/read-all');
                    await http.post(uri, headers: await _headers());
                    if (mounted) {
                      await _load();
                    }
                  },
            child: const Text('Read all'),
          ),
        ],
      ),
      body: _loading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final it = _items[i];
                      return ListTile(
                        title: Text(
                          it.title,
                          style: TextStyle(
                            fontWeight: it.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(it.body),
                        onTap: () async {
                          await _markRead(it);
                          if (it.deepLink != null &&
                              it.deepLink!.isNotEmpty) {
                            NotificationDeepLink.openFromData(
                              <String, dynamic>{'deep_link': it.deepLink},
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
