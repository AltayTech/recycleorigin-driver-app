import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Shown on the profile tab when the user is not authenticated.
class ProfileLoggedOutView extends StatelessWidget {
  const ProfileLoggedOutView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: AppTheme.bg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.account_circle_outlined,
                  size: 88,
                  color: colorScheme.primary.withValues(alpha: 0.55),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.notLoggedInLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.h1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginRequiredDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.grey,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(l10n.loginToAccountLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
