import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/features/guide_feature/domain/guide_cms_section.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Builds driver-relevant, non-empty CMS sections from shop info.
List<GuideCmsItem> guideCmsSectionsForDriver(
  AppLocalizations l10n,
  Shop shop,
) {
  final candidates = <GuideCmsItem>[
    GuideCmsItem(title: l10n.guideHowToUseLabel, html: shop.how_to_order),
    GuideCmsItem(title: l10n.faqLabel, html: shop.faq),
    GuideCmsItem(title: l10n.privacyPolicyLabel, html: shop.privacy),
  ];

  return candidates
      .where((s) => s.html.trim().isNotEmpty)
      .toList(growable: false);
}
