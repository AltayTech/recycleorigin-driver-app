import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';

/// Test double for [AuthBloc.login] without HTTP or Firebase.
class FakeAuthBloc extends AuthBloc {
  FakeAuthBloc({this.loginResult = false, this.loginThrows = false});

  final bool loginResult;
  final bool loginThrows;

  @override
  Future<bool> login(String email, String password) async {
    if (loginThrows) {
      throw Exception('simulated network failure');
    }
    if (loginResult) {
      emit(
        state.copyWith(
          token: 'test-token',
          isLoggedIn: true,
          emailVerified: true,
        ),
      );
    }
    return loginResult;
  }
}
