import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/data/firebase_auth_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/email_verification_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Driver registration screen for email/password Firebase accounts.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const double _spacingMd = 16;
  static const double _spacingLg = 24;
  static const double _radiusSm = 12;
  static const double _radiusMd = 20;

  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authBloc = context.read<AuthBloc>();
    try {
      final ok = await authBloc.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      if (ok) {
        Navigator.of(context).pushReplacementNamed(
          EmailVerificationScreen.routeName,
        );
      } else {
        _showErrorDialog(context.l10n.authGenericError);
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showErrorDialog(_mapAuthError(error, context.l10n));
      }
    } catch (_) {
      if (mounted) {
        _showErrorDialog(context.l10n.authGenericError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(ctx).colorScheme.error,
          size: 32,
        ),
        title: Text(l10n.loginErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
  }

  String _mapAuthError(AuthException error, AppLocalizations l10n) {
    switch (error.code) {
      case AuthErrorCodes.emailAlreadyInUse:
        return l10n.authEmailAlreadyRegistered;
      case AuthErrorCodes.invalidEmail:
        return l10n.authEmailInvalid;
      case AuthErrorCodes.weakPassword:
        return l10n.authPasswordTooShort;
      case AuthErrorCodes.networkRequestFailed:
        return l10n.authNetworkError;
      default:
        return l10n.authGenericError;
    }
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final l10n = context.l10n;
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return l10n.authEmailRequired;
    }
    if (!_emailRegex.hasMatch(email)) {
      return l10n.authEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.enterPasswordValidationMessage;
    }
    if (value.length < 8) {
      return context.l10n.authPasswordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final textTheme = theme.textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authRegisterButton)),
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.black.withValues(alpha: 0.62),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: _spacingMd,
                    right: _spacingMd,
                    top: _spacingLg,
                    bottom: _spacingLg + bottomInset,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - bottomInset,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Card(
                          elevation: 0,
                          color: colorScheme.surface.withValues(alpha: 0.98),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radiusMd),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(_spacingLg),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.authCreateAccountTitle,
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.authSubtitleSignUp,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: _spacingLg),
                                  _RegisterTextField(
                                    controller: _firstNameController,
                                    labelText: l10n.firstNameLabel,
                                    icon: Icons.person_outline_rounded,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.givenName,
                                    ],
                                    validator: (value) => _validateRequired(
                                      value,
                                      l10n.authFirstNameRequired,
                                    ),
                                  ),
                                  const SizedBox(height: _spacingMd),
                                  _RegisterTextField(
                                    controller: _lastNameController,
                                    labelText: l10n.lastNameLabel,
                                    icon: Icons.badge_outlined,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autofillHints: const [
                                      AutofillHints.familyName,
                                    ],
                                    validator: (value) => _validateRequired(
                                      value,
                                      l10n.authLastNameRequired,
                                    ),
                                  ),
                                  const SizedBox(height: _spacingMd),
                                  _RegisterTextField(
                                    controller: _emailController,
                                    labelText: l10n.emailLabel,
                                    hintText: l10n.emailHint,
                                    icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    autofillHints: const [
                                      AutofillHints.email,
                                    ],
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: _spacingMd),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: l10n.passwordHint,
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: colorScheme.primary,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _obscurePassword
                                            ? l10n.authShowPassword
                                            : l10n.authHidePassword,
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          );
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(_radiusSm),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (!_isLoading) {
                                        _submit();
                                      }
                                    },
                                    validator: _validatePassword,
                                  ),
                                  const SizedBox(height: _spacingLg),
                                  SizedBox(
                                    height: 48,
                                    child: FilledButton(
                                      onPressed: _isLoading ? null : _submit,
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            _radiusSm,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            )
                                          : Text(l10n.authRegisterButton),
                                    ),
                                  ),
                                  const SizedBox(height: _spacingMd),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.of(context)
                                                .pushReplacementNamed(
                                              LoginScreen.routeName,
                                            ),
                                    child: Text(l10n.authSwitchToLoginPrompt),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_RegisterScreenState._radiusSm),
        ),
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      autofillHints: autofillHints,
      validator: validator,
    );
  }
}
