import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches external map apps for turn-by-turn navigation.
class ExternalNavigationService {
  static const _prefKey = 'route_nav_preferred_app';

  Future<List<NavTarget>> availableTargets({
    required double lat,
    required double lng,
    String label = '',
  }) async {
    final encoded = Uri.encodeComponent(label);
    final candidates = <NavTarget>[
      NavTarget(
        id: 'google',
        label: 'Google Maps',
        uri: Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&destination=$lat,$lng&travelmode=driving',
        ),
        nativeUri: Uri.parse('google.navigation:q=$lat,$lng&mode=d'),
      ),
      NavTarget(
        id: 'waze',
        label: 'Waze',
        uri: Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes'),
        nativeUri: Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),
      ),
      NavTarget(
        id: 'geo',
        label: 'Maps',
        uri: Uri.parse('geo:$lat,$lng?q=$lat,$lng($encoded)'),
      ),
    ];
    final out = <NavTarget>[];
    for (final t in candidates) {
      if (t.nativeUri != null && await canLaunchUrl(t.nativeUri!)) {
        out.add(t);
      } else if (await canLaunchUrl(t.uri)) {
        out.add(t);
      }
    }
    if (out.isEmpty) {
      out.add(candidates.first);
    }
    return out;
  }

  Future<void> launch(NavTarget target) async {
    final uri = target.nativeUri ?? target.uri;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(target.uri, mode: LaunchMode.externalApplication);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, target.id);
  }

  Future<String?> preferredAppId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }
}

class NavTarget {
  const NavTarget({
    required this.id,
    required this.label,
    required this.uri,
    this.nativeUri,
  });

  final String id;
  final String label;
  final Uri uri;
  final Uri? nativeUri;
}
