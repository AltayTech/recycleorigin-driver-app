import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/request/pasmand.dart';
import 'package:recycleorigindriver/core/models/request/wasteCart.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_bloc.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_event.dart';
import 'package:recycleorigindriver/features/collect_feature/presentation/bloc/wastes_state.dart';

void main() {
  group('WastesBloc', () {
    blocTest<WastesBloc, WastesState>(
      'sPage updates pagination state',
      build: WastesBloc.new,
      act: (bloc) => bloc.sPage = 7,
      verify: (bloc) => expect(bloc.state.sPage, 7),
    );

    blocTest<WastesBloc, WastesState>(
      'searchBuilder encodes category when set',
      build: WastesBloc.new,
      act: (bloc) {
        bloc.add(WastesSearchParamsChanged(sCategory: 'metal'));
        bloc.searchBuilder();
      },
      verify: (bloc) {
        expect(bloc.state.searchEndPoint, contains('category=metal'));
      },
    );

    blocTest<WastesBloc, WastesState>(
      'searchBuilder builds page query from defaults',
      build: WastesBloc.new,
      act: (bloc) => bloc.searchBuilder(),
      verify: (bloc) {
        expect(bloc.state.searchEndPoint, contains('page=1'));
        expect(bloc.state.searchEndPoint, contains('per_page=10'));
        expect(bloc.state.searchEndPoint, contains('order=desc'));
        expect(bloc.state.searchEndPoint, contains('orderby=date'));
      },
    );

    test('addWasteCart updates matching cart isAdded', () async {
      final bloc = WastesBloc();
      final cart = WasteCart(
        pasmand: Pasmand(id: 42, post_title: 'Paper'),
        estimated_weight: '1',
        exact_weight: '1',
        estimated_price: '1',
        exact_price: '1',
        isAdded: false,
      );
      bloc.wasteCartItems = [cart];
      await bloc.addWasteCart(cart, true);
      expect(bloc.state.wasteCartItems.single.isAdded, isTrue);
      await bloc.close();
    });
  });
}
