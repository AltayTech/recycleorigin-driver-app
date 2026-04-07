import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/models/region.dart';
import 'package:recycleorigindriver/core/models/token_response_model.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';

void main() {
  group('AuthState', () {
    test('initial has empty token and is not authenticated', () {
      final s = AuthState.initial();
      expect(s.token, isEmpty);
      expect(s.isLoggedIn, isFalse);
      expect(s.isAuth, isFalse);
    });

    test('copyWith updates only provided fields', () {
      final base = AuthState.initial();
      final next = base.copyWith(
        token: 'jwt',
        isLoggedIn: true,
        isFirstLogin: true,
      );
      expect(next.token, 'jwt');
      expect(next.isLoggedIn, isTrue);
      expect(next.isFirstLogin, isTrue);
      expect(next.isCompleted, base.isCompleted);
    });

    test('isAuth is true when token is non-empty', () {
      final s = AuthState.initial().copyWith(token: 'x');
      expect(s.isAuth, isTrue);
    });

    test('selectedAddress can be replaced via copyWith', () {
      final region = Region(term_id: 1, name: 'R', collect_hour: []);
      final addr = Address(name: 'Home', address: 'St', region: region);
      final s = AuthState.initial().copyWith(selectedAddress: addr);
      expect(s.selectedAddress.name, 'Home');
      expect(s.selectedAddress.region.term_id, 1);
    });

    test('tokenResponseModel round-trips via copyWith', () {
      final model = TokenResponseModel(
        token: 't',
        userEmail: 'e@e.com',
      );
      final s = AuthState.initial().copyWith(tokenResponseModel: model);
      expect(s.tokenResponseModel.userEmail, 'e@e.com');
    });
  });
}
