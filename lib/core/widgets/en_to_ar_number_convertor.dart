import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

/// Eastern Arabic–Indic digits (٠–٩) for Arabic UI; other locales keep Latin
/// digits (0–9).
///
/// Use [localize] for any user-visible string that may contain digits. For
/// numeric amounts, use [decimalPatternFor] so grouping and decimal separators
/// follow the active language.
class EnArConvertor {
  EnArConvertor._();

  static const String _latinDigits = '0123456789';
  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';

  static bool usesEasternArabicDigits(Locale locale) =>
      locale.languageCode == 'ar';

  static String localizeForLocale(Locale locale, String text) {
    if (!usesEasternArabicDigits(locale)) return text;
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      final idx = _latinDigits.indexOf(ch);
      buffer.write(idx >= 0 ? _arabicIndicDigits[idx] : ch);
    }
    return buffer.toString();
  }

  static String localize(BuildContext context, String text) =>
      localizeForLocale(Localizations.localeOf(context), text);

  /// Decimal [NumberFormat] for the current app locale (e.g. Arabic–Indic
  /// digits and separators for Arabic).
  static intl.NumberFormat decimalPatternFor(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final String localeName = switch (lang) {
      'ar' => 'ar',
      'tr' => 'tr',
      _ => 'en',
    };
    return intl.NumberFormat.decimalPattern(localeName);
  }
}
