import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Sign-out button and confirmation dialog for profile flows.
class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.error,
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => ProfileLogout.handleLogout(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.logout_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              l10n.logoutLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared logout flow aligned with [MainDrawer].
class ProfileLogout {
  ProfileLogout._();

  static Future<void> handleLogout(BuildContext context) async {
    final parentContext = context;
    final l10n = parentContext.l10n;

    final bool? shouldNavigate = await showDialog<bool>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        var busy = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setD) {
            Future<void> onConfirm() async {
              setD(() => busy = true);
              try {
                parentContext.read<CustomerInfoBloc>().driver = parentContext
                    .read<CustomerInfoBloc>()
                    .driverZero;
                await parentContext.read<AuthBloc>().removeToken();
                if (!parentContext.mounted) {
                  return;
                }
                parentContext.read<AuthBloc>().isFirstLogout = true;
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(true);
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${parentContext.l10n.signOutErrorPrefix}$e',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(false);
                }
              } finally {
                if (ctx.mounted) {
                  setD(() => busy = false);
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.logoutLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Text(l10n.logoutConfirmMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancelLabel),
                ),
                TextButton(
                  onPressed: busy ? null : onConfirm,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: busy
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        )
                      : Text(
                          l10n.confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldNavigate == true && parentContext.mounted) {
      Navigator.of(parentContext).pushNamedAndRemoveUntil(
        NavigationBottomScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }
}
