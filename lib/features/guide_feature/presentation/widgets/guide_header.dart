import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Compact shop branding header on the Help screen.
class GuideHeader extends StatelessWidget {
  const GuideHeader({super.key, required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediumLogo = shop.logo.sizes.medium.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (mediumLogo.isNotEmpty)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mediumLogo,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.storefront_rounded,
                  size: 48,
                  color: context.secondaryText,
                ),
              ),
            ),
          )
        else
          Icon(
            Icons.recycling_rounded,
            size: 48,
            color: scheme.primary,
          ),
        const SizedBox(height: 12),
        Text(
          shop.name.isNotEmpty ? shop.name : context.l10n.guideLabel,
          style: textTheme.titleLarge?.copyWith(
            color: context.primaryText,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (shop.subject.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            shop.subject,
            style: textTheme.bodyMedium?.copyWith(
              color: context.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
