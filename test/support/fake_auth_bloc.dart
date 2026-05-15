import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';

/// Test double for [AuthBloc.login] without HTTP or secure storage.
class FakeAuthBloc extends AuthBloc {
  FakeAuthBloc({
    this.loginResult = false,
    this.loginThrows = false,
  });

  final bool loginResult;
  final bool loginThrows;

  @override
  Future<bool> login(String email, String password) async {
    if (loginThrows) {
      throw Exception('simulated network failure');
    }
    return loginResult;
  }
}
