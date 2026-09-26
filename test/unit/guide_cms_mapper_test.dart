import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recycleorigindriver/core/models/featured_image.dart';
import 'package:recycleorigindriver/core/models/shop.dart';
import 'package:recycleorigindriver/core/models/sizes.dart';
import 'package:recycleorigindriver/core/models/social_media.dart';
import 'package:recycleorigindriver/features/guide_feature/domain/guide_cms_mapper.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';

Shop _shop({String privacy = ''}) {
  return Shop(
    support_phone: '',
    logo: FeaturedImage(id: 0, title: '', sizes: const Sizes()),
    return_policy: '',
    privacy: privacy,
    how_to_order: '',
    faq: '',
    pay_methods_desc: '',
    word_hours: '',
    address: '',
    social_media: SocialMedia(telegram: '', instagram: ''),
    name: 'RecycleOrigin',
    subject: '',
    slug: '',
    phone: '',
    mobile: '',
    about: '',
    features_list: const [],
    featured_image: FeaturedImage(id: 0, title: '', sizes: const Sizes()),
    gallery: const [],
    policy: '',
  );
}

void main() {
  test('always appends a Location help section', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final sections = guideCmsSectionsForDriver(l10n, _shop());

    expect(sections, isNotEmpty);
    expect(sections.last.title, 'Location');
    expect(sections.last.html, contains('precise location'));
    expect(sections.last.html, contains('when the app is not in use'));
  });

  test('keeps CMS privacy and still appends Location', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final sections = guideCmsSectionsForDriver(
      l10n,
      _shop(privacy: '<p>CMS privacy</p>'),
    );

    expect(sections.map((s) => s.title), contains('Privacy policy'));
    expect(sections.last.title, 'Location');
  });
}
