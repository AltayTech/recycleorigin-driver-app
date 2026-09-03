import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/location/position_upload_throttle.dart';

void main() {
  test('allows first upload immediately', () {
    final throttle = PositionUploadThrottle(
      minInterval: const Duration(seconds: 20),
    );
    expect(throttle.shouldUpload(DateTime.utc(2026, 1, 1)), isTrue);
  });

  test('blocks upload inside interval', () {
    final throttle = PositionUploadThrottle(
      minInterval: const Duration(seconds: 20),
    );
    final first = DateTime.utc(2026, 1, 1, 12);
    throttle.markUploaded(first);
    expect(
      throttle.shouldUpload(first.add(const Duration(seconds: 10))),
      isFalse,
    );
    expect(
      throttle.shouldUpload(first.add(const Duration(seconds: 20))),
      isTrue,
    );
  });
}
