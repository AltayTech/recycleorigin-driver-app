import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/network/urls.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Display helpers for driver identity on profile screens.
class DriverDisplay {
  DriverDisplay._();

  static String name(Driver driver, AppLocalizations l10n) {
    final fname = driver.driver_data.fname.trim();
    final lname = driver.driver_data.lname.trim();
    final email = driver.driver_data.email.trim();
    final mobile = driver.driver_data.mobile.trim();

    if (fname.isNotEmpty || lname.isNotEmpty) {
      return '$fname $lname'.trim();
    }
    if (email.isNotEmpty) {
      return email;
    }
    if (mobile.isNotEmpty) {
      return mobile;
    }
    return l10n.userProfileLabel;
  }

  static String subtitle(Driver driver) {
    final data = driver.driver_data;
    final email = data.email.trim();
    if (email.isNotEmpty) {
      return email;
    }
    final mobile = data.mobile.trim();
    if (mobile.isNotEmpty) {
      return mobile;
    }
    return data.phone.trim();
  }

  static String initials(String displayName) {
    final tokens = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String t) => t.isNotEmpty);
    final initials =
        tokens.take(2).map((String t) => t[0]).join().toUpperCase();
    return initials.isEmpty ? 'D' : initials;
  }

  static String? imageUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = Urls.apiBaseUrl.endsWith('/')
        ? Urls.apiBaseUrl.substring(0, Urls.apiBaseUrl.length - 1)
        : Urls.apiBaseUrl;
    if (trimmed.startsWith('/')) {
      return '$base$trimmed';
    }
    return '$base/$trimmed';
  }
}
