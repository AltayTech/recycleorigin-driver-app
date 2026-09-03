import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Wallet / rating / stores summary card overlapping the profile hero.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ratingText = driver.averageRating != null
        ? driver.averageRating!.toStringAsFixed(1)
        : l10n.noRatingLabel;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _HeroStatChip(
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.walletBalanceLabel,
                value: driver.money.trim().isNotEmpty ? driver.money : '—',
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _HeroStatChip(
                icon: Icons.star_rounded,
                label: l10n.ratingLabel,
                value: ratingText,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _HeroStatChip(
                icon: Icons.store_outlined,
                label: l10n.storesCountLabel,
                value: '${driver.stores.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.secondaryText),
        ),
      ],
    );
  }
}
