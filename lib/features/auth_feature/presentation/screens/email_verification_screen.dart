import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/data/firebase_auth_service.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Shown after sign-up or when an authenticated driver still needs to
/// verify their email. The screen polls Firebase for verification only on
/// user action (`I've verified`) and lets the user resend the verification
/// email at most once per 60 seconds.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  static const routeName = '/auth/verify-email';

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  static const _resendCooldown = Duration(seconds: 60);
  static const _spacingSm = 12.0;
  static const _spacingMd = 16.0;
  static const _spacingLg = 24.0;

  bool _isChecking = false;
  bool _isResending = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _secondsRemaining = _resendCooldown.inSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRemaining -= 1);
      if (_secondsRemaining <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      await context.read<AuthBloc>().resendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authVerifyEmailResentSuccess)),
      );
      _startCooldown();
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authGenericError)),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final verified =
          await context.read<AuthBloc>().refreshEmailVerification();
      if (!mounted) return;
      if (verified) {
        Navigator.of(context)
            .pushReplacementNamed(NavigationBottomScreen.routeName);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authVerifyEmailNotYet)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authGenericError)),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _signOut() async {
    await context.read<AuthBloc>().removeToken();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final email = context.select<AuthBloc, String>(
          (b) => b.state.tokenResponseModel.userEmail ?? '',
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.authVerifyEmailTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_spacingLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: _spacingMd),
                Text(
                  l10n.authVerifyEmailSubtitle(email),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _spacingLg),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isChecking ? null : _checkVerified,
                    child: _isChecking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.authVerifyEmailIveVerified),
                  ),
                ),
                const SizedBox(height: _spacingSm),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: (_secondsRemaining > 0 || _isResending)
                        ? null
                        : _resend,
                    child: _isResending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _secondsRemaining > 0
                                ? l10n.authVerifyEmailResendIn(
                                    _secondsRemaining,
                                  )
                                : l10n.authVerifyEmailResend,
                          ),
                  ),
                ),
                const SizedBox(height: _spacingMd),
                TextButton(
                  onPressed: _signOut,
                  child: Text(l10n.authVerifyEmailLogout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
