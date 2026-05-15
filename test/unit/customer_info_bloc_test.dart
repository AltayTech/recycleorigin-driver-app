import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';

void main() {
  group('CustomerInfoBloc', () {
    blocTest<CustomerInfoBloc, CustomerInfoState>(
      'searchBuilder builds endpoint from pagination',
      build: CustomerInfoBloc.new,
      act: (bloc) {
        bloc.sPage = 3;
        bloc.searchBuilder();
      },
      verify: (bloc) {
        expect(bloc.state.searchEndPoint, contains('page=3'));
        expect(bloc.state.searchEndPoint, contains('per_page=10'));
      },
    );

    blocTest<CustomerInfoBloc, CustomerInfoState>(
      'CustomerInfoDriverSet replaces driver',
      build: CustomerInfoBloc.new,
      act: (bloc) {
        final next = Driver.fromJson({'car_number': 'PLATE-99'});
        bloc.driver = next;
      },
      verify: (bloc) {
        expect(bloc.state.driver.car_number, 'PLATE-99');
      },
    );

    test('driverZero matches Driver.fromJson(null)', () {
      final bloc = CustomerInfoBloc();
      expect(bloc.driverZero.car_number, bloc.state.driver.car_number);
      bloc.close();
    });
  });
}
