import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_bloc.dart';
import 'package:recycleorigindriver/features/delivery_feature/presentation/bloc/deliveries_state.dart';

void main() {
  group('DeliveriesBloc', () {
    blocTest<DeliveriesBloc, DeliveriesState>(
      'sPerPage updates state',
      build: DeliveriesBloc.new,
      act: (bloc) => bloc.sPerPage = 20,
      verify: (bloc) => expect(bloc.state.sPerPage, 20),
    );

    blocTest<DeliveriesBloc, DeliveriesState>(
      'searchBuilder includes category param',
      build: DeliveriesBloc.new,
      act: (bloc) {
        bloc.sCategory = 'plastic';
        bloc.searchBuilder();
      },
      verify: (bloc) {
        expect(bloc.state.searchEndPoint, contains('category=plastic'));
      },
    );
  });
}
