import 'package:recycleorigindriver/core/utils/gregorian_date_format.dart';

/// Formats a stop timestamp for driver UI (local date · 24h time, no
/// fractional seconds).
String formatStopDateTime(DateTime value) {
  final local = value.toLocal();
  return '${GregorianDateFormat.dateYmd(local)} · '
      '${GregorianDateFormat.timeHm(local)}';
}

/// Planned arrival, or a same-day arrival–departure window.
String? formatStopSchedule({DateTime? arrival, DateTime? departure}) {
  if (arrival == null && departure == null) {
    return null;
  }
  if (arrival != null && departure != null) {
    final start = arrival.toLocal();
    final end = departure.toLocal();
    final sameDay =
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) {
      return '${GregorianDateFormat.dateYmd(start)} · '
          '${GregorianDateFormat.timeHm(start)}–'
          '${GregorianDateFormat.timeHm(end)}';
    }
    return '${formatStopDateTime(arrival)} – '
        '${formatStopDateTime(departure)}';
  }
  return formatStopDateTime(arrival ?? departure!);
}

/// Compact weight for labels. Empty when the API sent no demand.
String formatStopWeightKg(double kg) {
  if (kg <= 0) {
    return '';
  }
  if (kg == kg.roundToDouble()) {
    return kg.toInt().toString();
  }
  return kg.toStringAsFixed(1);
}

/// True when the stop has a usable map pin (0,0 is treated as missing).
bool stopHasMapCoordinates(double lat, double lng) {
  if (lat == 0 && lng == 0) {
    return false;
  }
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}
