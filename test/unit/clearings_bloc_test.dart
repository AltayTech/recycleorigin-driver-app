import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_bloc.dart';
import 'package:recycleorigindriver/features/clearing_feature/presentation/bloc/clearings_state.dart';

void main() {
  group('ClearingsBloc', () {
    blocTest<ClearingsBloc, ClearingsState>(
      'sOrder updates sort direction in state',
      build: ClearingsBloc.new,
      act: (bloc) => bloc.sOrder = 'asc',
      verify: (bloc) => expect(bloc.state.sOrder, 'asc'),
    );

    blocTest<ClearingsBloc, ClearingsState>(
      'searchBuilder reflects order and orderby',
      build: ClearingsBloc.new,
      act: (bloc) {
        bloc.sOrderBy = 'date';
        bloc.searchBuilder();
      },
      verify: (bloc) {
        expect(bloc.state.searchEndPoint, contains('orderby=date'));
      },
    );
  });
}
