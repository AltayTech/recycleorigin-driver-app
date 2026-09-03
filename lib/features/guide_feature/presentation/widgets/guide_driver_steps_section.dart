import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/navigation/driver_shell_tab_request.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/guide_navigation.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_step_tile.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Native driver workflow steps with deep links into the app.
class GuideDriverStepsSection extends StatelessWidget {
  const GuideDriverStepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    final steps =
        <({IconData icon, String title, String subtitle, VoidCallback onTap})>[
          (
            icon: Icons.local_shipping_outlined,
            title: l10n.guideStepCollectionTitle,
            subtitle: l10n.guideStepCollectionSubtitle,
            onTap: () => navigateToDriverShellTab(
              context,
              DriverShellTabIndex.collection,
            ),
          ),
          (
            icon: Icons.route_outlined,
            title: l10n.guideStepRouteTitle,
            subtitle: l10n.guideStepRouteSubtitle,
            onTap: () => navigateToRouteToday(context),
          ),
          (
            icon: Icons.store_outlined,
            title: l10n.guideStepWarehouseTitle,
            subtitle: l10n.guideStepWarehouseSubtitle,
            onTap: () => navigateToDriverShellTab(
              context,
              DriverShellTabIndex.warehouse,
            ),
          ),
          (
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.guideStepWalletTitle,
            subtitle: l10n.guideStepWalletSubtitle,
            onTap: () =>
                navigateToDriverShellTab(context, DriverShellTabIndex.wallet),
          ),
          (
            icon: Icons.insights_outlined,
            title: l10n.guideStepPerformanceTitle,
            subtitle: l10n.guideStepPerformanceSubtitle,
            onTap: () => navigateToDriverShellTab(
              context,
              DriverShellTabIndex.performance,
            ),
          ),
          (
            icon: Icons.support_agent_outlined,
            title: l10n.guideStepSupportTitle,
            subtitle: l10n.guideStepSupportSubtitle,
            onTap: () => navigateToSupportTickets(context),
          ),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.guideHowItWorksTitle,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.secondaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shadowColor: Colors.black26,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: scheme.surface,
          child: Column(
            children: <Widget>[
              for (var i = 0; i < steps.length; i++)
                GuideStepTile(
                  icon: steps[i].icon,
                  title: steps[i].title,
                  subtitle: steps[i].subtitle,
                  onTap: steps[i].onTap,
                  showDivider: i < steps.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
