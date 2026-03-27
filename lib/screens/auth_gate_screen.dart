import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/screens/customer_info/login_screen.dart';
import 'package:recycleorigindriver/screens/navigation_bottom_screen.dart';

/// After splash: loads stored token and redirects to Login or Home.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthBloc>();
    await auth.loadStoredToken();
    if (!mounted) return;
    if (auth.state.isAuth) {
      Navigator.of(context).pushReplacementNamed(
        NavigationBottomScreen.routeName,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
