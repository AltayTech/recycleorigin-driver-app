import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/features/guide_feature/domain/guide_cms_section.dart'
    show GuideCmsItem;
import 'package:recycleorigindriver/features/guide_feature/presentation/screens/guide_policy_detail_screen.dart';
import 'package:recycleorigindriver/features/guide_feature/presentation/widgets/guide_policy_tile.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// CMS-backed policies and FAQ list (non-empty sections only).
class GuideCmsSection extends StatelessWidget {
  const GuideCmsSection({super.key, required this.sections});

  final List<GuideCmsItem> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.guidePoliciesSectionTitle,
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
              for (var i = 0; i < sections.length; i++)
                GuidePolicyTile(
                  title: sections[i].title,
                  showDivider: i < sections.length - 1,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GuidePolicyDetailScreen(
                          title: sections[i].title,
                          html: sections[i].html,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
