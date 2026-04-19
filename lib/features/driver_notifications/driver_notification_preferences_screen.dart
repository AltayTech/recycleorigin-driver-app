import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/notifications/driver_push_notification_controller.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';

class DriverNotificationPreferencesScreen extends StatefulWidget {
  static const routeName = '/driverNotificationPrefs';

  const DriverNotificationPreferencesScreen({super.key});

  @override
  State<DriverNotificationPreferencesScreen> createState() =>
      _DriverNotificationPreferencesScreenState();
}

class _DriverNotificationPreferencesScreenState
    extends State<DriverNotificationPreferencesScreen> {
  final Map<String, Map<String, bool>> _prefs = {
    'transactional': {'push': true, 'inapp': true},
    'marketing': {'push': true, 'inapp': true},
  };
  bool _loading = true;
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
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> _load() async {
    final uri = Uri.parse('${Urls.rootUrl}/notifications/preferences');
    final res = await http.get(uri, headers: await _headers());
    if (!mounted) {
      return;
    }
    if (res.statusCode != 200) {
      setState(() {
        _loading = false;
        _error = 'Failed to load';
      });
      return;
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      final cat = m['category'] as String? ?? '';
      final ch = m['channel'] as String? ?? '';
      final en = m['enabled'] as bool? ?? true;
      _prefs.putIfAbsent(cat, () => {'push': true, 'inapp': true});
      if (ch == 'push' || ch == 'inapp') {
        _prefs[cat]![ch] = en;
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final items = <Map<String, dynamic>>[];
    _prefs.forEach((cat, chMap) {
      chMap.forEach((ch, en) {
        items.add(<String, dynamic>{
          'category': cat,
          'channel': ch,
          'enabled': en,
        });
      });
    });
    final uri = Uri.parse('${Urls.rootUrl}/notifications/preferences');
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{'items': items}),
    );
    if (!mounted) {
      return;
    }
    if (res.statusCode == 200) {
      await DriverPushNotificationController.instance.syncAfterLogin();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: const Text('Notification settings'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  children: [
                    for (final cat in _prefs.keys)
                      ExpansionTile(
                        title: Text(cat),
                        children: [
                          SwitchListTile(
                            title: const Text('Push'),
                            value: _prefs[cat]!['push']!,
                            onChanged: (v) => setState(
                              () => _prefs[cat]!['push'] = v,
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('In-app inbox'),
                            value: _prefs[cat]!['inapp']!,
                            onChanged: (v) => setState(
                              () => _prefs[cat]!['inapp'] = v,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
}
