import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/route_feature/presentation/stop_schedule_format.dart';

void main() {
  test('formatStopDateTime omits fractional seconds', () {
    final value = DateTime(2026, 9, 5, 17, 41, 55, 162);
    expect(formatStopDateTime(value), '2026/09/05 · 17:41');
    expect(formatStopDateTime(value), isNot(contains('162')));
  });

  test('formatStopSchedule collapses a same-day window', () {
    final start = DateTime(2026, 9, 5, 17, 41);
    final end = DateTime(2026, 9, 5, 18, 10);
    expect(
      formatStopSchedule(arrival: start, departure: end),
      '2026/09/05 · 17:41–18:10',
    );
  });

  test('formatStopWeightKg hides empty demand', () {
    expect(formatStopWeightKg(0), isEmpty);
    expect(formatStopWeightKg(2), '2');
    expect(formatStopWeightKg(2.5), '2.5');
  });

  test('stopHasMapCoordinates treats origin as missing', () {
    expect(stopHasMapCoordinates(0, 0), isFalse);
    expect(stopHasMapCoordinates(41.04, 28.98), isTrue);
  });
}
