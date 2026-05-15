import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';

void main() {
  group('RequestWasteItem', () {
    test('needsDriverAcceptOrReject when driver_accepted is false', () {
      final item = RequestWasteItem.fromJson({
        'id': 1,
        'driver_accepted': false,
      });
      expect(item.needsDriverAcceptOrReject, isTrue);
    });

    test('needsDriverAcceptOrReject is false when driver_accepted is true', () {
      final item = RequestWasteItem.fromJson({
        'id': 1,
        'driver_accepted': true,
      });
      expect(item.needsDriverAcceptOrReject, isFalse);
    });

    test('needsDriverAcceptOrReject is false when driver_accepted omitted', () {
      final item = RequestWasteItem.fromJson({'id': 2});
      expect(item.needsDriverAcceptOrReject, isFalse);
    });

    test('fromJson reads request_status_key', () {
      final item = RequestWasteItem.fromJson({
        'id': 3,
        'request_status_key': 'pending_assignment',
      });
      expect(item.requestStatusKey, 'pending_assignment');
    });
  });
}
