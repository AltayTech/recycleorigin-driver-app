import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';

void main() {
  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'AuthFirstLoginSet updates isFirstLogin',
      build: AuthBloc.new,
      act: (bloc) => bloc.add(AuthFirstLoginSet(true)),
      verify: (bloc) {
        expect(bloc.state.isFirstLogin, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthFirstLogoutSet updates isFirstLogout',
      build: AuthBloc.new,
      act: (bloc) => bloc.add(AuthFirstLogoutSet(true)),
      verify: (bloc) {
        expect(bloc.state.isFirstLogout, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthSelectAddressRequested updates selectedAddress',
      build: AuthBloc.new,
      act: (bloc) {
        final region = Region(term_id: 2, name: 'Zone', collect_hour: []);
        final addr = Address(name: 'A', address: 'B', region: region);
        bloc.add(AuthSelectAddressRequested(addr));
      },
      verify: (bloc) {
        expect(bloc.state.selectedAddress.name, 'A');
        expect(bloc.state.selectedAddress.region.name, 'Zone');
      },
    );
  });
}