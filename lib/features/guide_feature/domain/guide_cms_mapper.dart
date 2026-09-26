import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/features/guide_feature/domain/guide_cms_section.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

/// Builds driver-relevant, non-empty CMS sections from shop info.
///
/// Always includes a Location section so Play reviewers can find where
/// and when GPS is used even if CMS privacy HTML is empty.
List<GuideCmsItem> guideCmsSectionsForDriver(AppLocalizations l10n, Shop shop) {
  final candidates = <GuideCmsItem>[
    GuideCmsItem(title: l10n.guideHowToUseLabel, html: shop.how_to_order),
    GuideCmsItem(title: l10n.faqLabel, html: shop.faq),
    GuideCmsItem(title: l10n.privacyPolicyLabel, html: shop.privacy),
  ];

  final sections = candidates
      .where((s) => s.html.trim().isNotEmpty)
      .toList(growable: true);
  sections.add(
    GuideCmsItem(
      title: l10n.locationHelpSectionTitle,
      html: '<p>${l10n.locationDisclosureBody}</p>',
    ),
  );
  return List<GuideCmsItem>.unmodifiable(sections);
}
