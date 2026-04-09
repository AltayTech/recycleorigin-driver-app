import 'dart:developer' as developer;

import 'package:url_launcher/url_launcher.dart';

/// Opens coordinates in the user's installed maps app (Google Maps, Apple Maps,
/// etc.) using platform-agnostic https URLs with [LaunchMode.externalApplication].
final class ExternalMaps {
  ExternalMaps._();

  /// Parses [latitude] and [longitude] strings from the API (commas as decimal
  /// separator are normalized). Returns `(null, null)` if invalid or out of range.
  static (double?, double?) parseCoordinates(String latRaw, String lngRaw) {
    final lat = double.tryParse(latRaw.trim().replaceAll(',', '.'));
    final lng = double.tryParse(lngRaw.trim().replaceAll(',', '.'));
    if (lat == null || lng == null) {
      return (null, null);
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return (null, null);
    }
    return (lat, lng);
  }

  /// Tries Google Maps (https) first, then the [geo:] scheme where supported.
  static Future<bool> openInExternalMaps(
    double latitude,
    double longitude,
  ) async {
    final google = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final geo = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');

    try {
      if (await canLaunchUrl(google)) {
        final ok = await launchUrl(google, mode: LaunchMode.externalApplication);
        if (ok) {
          return true;
        }
      }
    } catch (e, st) {
      developer.log(
        'Google Maps launch failed',
        name: 'ExternalMaps',
        error: e,
        stackTrace: st,
      );
    }

    try {
      if (await canLaunchUrl(geo)) {
        return launchUrl(geo, mode: LaunchMode.externalApplication);
      }
    } catch (e, st) {
      developer.log(
        'geo: launch failed',
        name: 'ExternalMaps',
        error: e,
        stackTrace: st,
      );
    }

    try {
      return await launchUrl(google, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      developer.log(
        'Fallback launch failed',
        name: 'ExternalMaps',
        error: e,
        stackTrace: st,
      );
    }
    return false;
  }
}
