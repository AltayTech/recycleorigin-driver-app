import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/request/request_waste_item.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_state.dart';

void main() {
  group('WastesState', () {
    test('copyWith clearRequestWasteItem clears selection', () {
      final item = RequestWasteItem.fromJson({'id': 99});
      final withItem = WastesState.initial().copyWith(requestWasteItem: item);
      final cleared = withItem.copyWith(clearRequestWasteItem: true);
      expect(cleared.requestWasteItem, isNull);
    });

    test('copyWith clearSearchDetails clears search meta', () {
      final base = WastesState.initial();
      final cleared = base.copyWith(clearSearchDetails: true);
      expect(cleared.searchDetails, isNull);
    });

    test('copyWith updates pagination fields', () {
      final s = WastesState.initial().copyWith(
        sPage: 3,
        sPerPage: 25,
        sOrder: 'asc',
        sOrderBy: 'title',
      );
      expect(s.sPage, 3);
      expect(s.sPerPage, 25);
      expect(s.sOrder, 'asc');
      expect(s.sOrderBy, 'title');
    });
  });
}
