import 'package:flutter/foundation.dart';

import 'package:recycleorigindriver/core/models/social_media.dart';
import 'feature.dart';
import 'featured_image.dart';

class Shop with ChangeNotifier {
  final String support_phone;
  final FeaturedImage logo;
  final String return_policy;
  final String privacy;
  final String how_to_order;
  final String faq;
  final String pay_methods_desc;
  final String word_hours;
  final String address;
  final SocialMedia social_media;
  final String name;
  final String subject;
  final String slug;
  final String phone;
  final String mobile;
  final String about;
  final List<Feature> features_list;
  final FeaturedImage featured_image;
  final List<FeaturedImage> gallery;
  final String policy;

  Shop({
    required this.support_phone,
    required this.logo,
    required this.return_policy,
    required this.privacy,
    required this.how_to_order,
    required this.faq,
    required this.pay_methods_desc,
    required this.word_hours,
    required this.address,
    required this.social_media,
    required this.name,
    required this.subject,
    required this.slug,
    required this.phone,
    required this.mobile,
    required this.about,
    required this.features_list,
    required this.featured_image,
    required this.gallery,
    required this.policy,
  });

  factory Shop.fromJson(Map<String, dynamic> parsedJson) {
    final galleryList = parsedJson['gallery'];
    final galleryRaw = galleryList is List
        ? galleryList
            .map((dynamic i) => FeaturedImage.fromJson(i))
            .toList()
        : <FeaturedImage>[];

    final featureList = parsedJson['features_list'];
    final featureRaw = featureList is List
        ? featureList.map((dynamic i) => Feature.fromJson(i)).toList()
        : <Feature>[];

    return Shop(
      support_phone: parsedJson['support_phone'] as String? ?? '',
      logo: FeaturedImage.fromJson(parsedJson['logo']),
      return_policy: parsedJson['return_policy'] as String? ?? '',
      privacy: parsedJson['privacy'] as String? ?? '',
      how_to_order: parsedJson['how_to_order'] as String? ?? '',
      faq: parsedJson['faq'] as String? ?? '',
      pay_methods_desc: parsedJson['pay_methods_desc'] as String? ?? '',
      word_hours: parsedJson['word_hours'] as String? ?? '',
      address: parsedJson['address'] as String? ?? '',
      social_media: SocialMedia.fromJson(parsedJson['social_media']),
      name: parsedJson['name'] as String? ?? '',
      subject: parsedJson['subject'] as String? ?? '',
      slug: parsedJson['slug'] as String? ?? '',
      phone: parsedJson['phone'] as String? ?? '',
      mobile: parsedJson['mobile'] as String? ?? '',
      about: parsedJson['about'] as String? ?? '',
      features_list: featureRaw,
      featured_image: FeaturedImage.fromJson(parsedJson['featured_image']),
      gallery: galleryRaw,
      policy: parsedJson['policy'] as String? ?? '',
    );
  }
}
