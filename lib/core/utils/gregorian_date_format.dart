/// Local Gregorian (Christian) calendar formatting helpers.
///
/// Used wherever the driver app shows a numeric date/time string (no Jalali).
class GregorianDateFormat {
  GregorianDateFormat._();

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// `yyyy/MM/dd` in the device local calendar.
  static String dateYmd(DateTime local) =>
      '${local.year}/${_twoDigits(local.month)}/${_twoDigits(local.day)}';

  /// `HH:mm` (24h) local time.
  static String timeHm(DateTime local) =>
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}
