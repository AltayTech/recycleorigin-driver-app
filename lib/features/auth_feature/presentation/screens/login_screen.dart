import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/main_drawer.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';

/// Login screen: email + password, same flow and API as main Recycle Origin app.
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: MainDrawer(),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: deviceSize.height * 0.1,
                child: SizedBox(
                  height: deviceSize.height * 0.99,
                  width: deviceSize.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 30,
                          ),
                          child: Text(
                            context.l10n.wasteManagementSystemTitle,
                            style: TextStyle(
                              fontFamily: 'BFarnaz',
                              fontWeight: FontWeight.w900,
                              color: Colors.green,
                              fontSize: textScaleFactor * 28.0,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: deviceSize.width > 600 ? 2 : 1,
                        child: const _AuthCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatefulWidget {
  const _AuthCard();

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.loginErrorTitle),
        content: Text(message),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.confirmLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthBloc>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pushReplacementNamed(
          NavigationBottomScreen.routeName,
        );
      } else {
        _showErrorDialog(context.l10n.invalidCredentialsMessage);
      }
    } catch (_) {
      if (mounted) {
        _showErrorDialog(context.l10n.connectionRetryMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: deviceSize.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildEmailField(textScaleFactor, deviceSize),
              _buildPasswordField(textScaleFactor, deviceSize),
              const SizedBox(height: 20),
              _isLoading
                  ? SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      height: deviceSize.height * 0.055,
                      width: deviceSize.width * 0.6,
                      child: FilledButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _submit();
                        },
                        child: Text(
                          context.l10n.loginLabel,
                          style: TextStyle(
                            color: AppTheme.bg,
                            fontSize: textScaleFactor * 13.0,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(double textScaleFactor, Size deviceSize) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: SizedBox(
          height: deviceSize.height * 0.055,
          width: deviceSize.width * 0.6,
          child: TextFormField(
            controller: _emailController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: context.l10n.emailHint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.enterEmailValidationMessage;
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(double textScaleFactor, Size deviceSize) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: SizedBox(
          height: deviceSize.height * 0.055,
          width: deviceSize.width * 0.6,
          child: TextFormField(
            controller: _passwordController,
            textAlign: TextAlign.center,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: context.l10n.passwordHint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterPasswordValidationMessage;
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
