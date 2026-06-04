import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/core/storage/secure_storage.dart';

/// A single notification preference channel toggle.
class NotificationPreferenceItem {
  const NotificationPreferenceItem({
    required this.category,
    required this.channel,
    required this.enabled,
  });

  final String category;
  final String channel;
  final bool enabled;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'category': category,
        'channel': channel,
        'enabled': enabled,
      };
}

/// Loads and persists driver notification preferences via the API.
class NotificationPreferencesService {
  NotificationPreferencesService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken() ?? '';
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Default preferences when the API returns nothing.
  static Map<String, Map<String, bool>> defaultPrefs() =>
      <String, Map<String, bool>>{
        'transactional': <String, bool>{'push': true, 'inapp': true},
        'marketing': <String, bool>{'push': true, 'inapp': true},
      };

  Future<Map<String, Map<String, bool>>> fetch() async {
    final uri = Uri.parse('${Urls.rootUrl}/notifications/preferences');
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? <dynamic>[];
    final prefs = defaultPrefs();
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      final cat = m['category'] as String? ?? '';
      final ch = m['channel'] as String? ?? '';
      final en = m['enabled'] as bool? ?? true;
      prefs.putIfAbsent(cat, () => <String, bool>{'push': true, 'inapp': true});
      if (ch == 'push' || ch == 'inapp') {
        prefs[cat]![ch] = en;
      }
    }
    return prefs;
  }

  Future<void> save(Map<String, Map<String, bool>> prefs) async {
    final items = <NotificationPreferenceItem>[];
    prefs.forEach((cat, chMap) {
      chMap.forEach((ch, en) {
        items.add(
          NotificationPreferenceItem(
            category: cat,
            channel: ch,
            enabled: en,
          ),
        );
      });
    });
    final uri = Uri.parse('${Urls.rootUrl}/notifications/preferences');
    final res = await _client.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(<String, dynamic>{
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
  }
}
