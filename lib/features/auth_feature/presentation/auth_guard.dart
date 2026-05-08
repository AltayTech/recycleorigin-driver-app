import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/email_verification_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';

/// Routes the driver to the right gate (login or verify-email) for entry
/// points that need an authenticated and verified account.
///
/// Returns `true` if the driver can proceed, otherwise navigates to the
/// appropriate auth screen and returns `false`.
bool requireVerifiedEmail(BuildContext context) {
  final state = context.read<AuthBloc>().state;
  if (!state.isAuth) {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
    return false;
  }
  if (!state.emailVerified) {
    Navigator.of(context).pushNamed(EmailVerificationScreen.routeName);
    return false;
  }
  return true;
}

/// Wrapper widget that shows [child] only when the driver is signed in and
/// has a verified email; otherwise navigates to the right auth screen.
class VerifiedAuthGate extends StatelessWidget {
  const VerifiedAuthGate({
    super.key,
    required this.child,
    this.fallback,
  });

  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) =>
          prev.isAuth != curr.isAuth ||
          prev.emailVerified != curr.emailVerified,
      builder: (context, state) {
        if (state.isAuth && state.emailVerified) {
          return child;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (!state.isAuth) {
            Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          } else {
            Navigator.of(context)
                .pushReplacementNamed(EmailVerificationScreen.routeName);
          }
        });
        return fallback ??
            const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}
