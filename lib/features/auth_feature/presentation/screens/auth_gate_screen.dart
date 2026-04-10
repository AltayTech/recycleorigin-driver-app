import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/screens/navigation_bottom_screen.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/en_to_ar_number_convertor.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/features/auth_feature/presentation/screens/login_screen.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Cold start: shows branding while the session is restored, then opens home
/// or login.
///
/// Navigation runs as soon as [AuthBloc.loadStoredToken] finishes (no fixed
/// splash delay), which matches common app-store guidance.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveDestination());
  }

  Future<void> _resolveDestination() async {
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
    final viewSize = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final logoSize = viewSize.shortestSide * 0.42;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final viewPad = MediaQuery.viewPaddingOf(context);
            final bgW = w + viewPad.horizontal;
            final bgH = h + viewPad.vertical;

            return Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: -viewPad.left,
                  top: -viewPad.top,
                  width: bgW,
                  height: bgH,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 1.03,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/login_bg.png',
                        fit: BoxFit.cover,
                        width: bgW,
                        height: bgH,
                        alignment: Alignment.center,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Image.asset(
                        'assets/images/splash_main.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          context.l10n.splashTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppTheme.h1,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          EnArConvertor.localize(
                            context,
                            context.l10n.splashVersionLabel,
                          ),
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.h1.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      SizedBox(height: viewSize.height * 0.05),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
