import 'package:flutter/foundation.dart';

import '../models/social_media.dart';
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
    var galleryList = parsedJson['gallery'] as List;
    List<FeaturedImage> galleryRaw =
        galleryList.map((i) => FeaturedImage.fromJson(i)).toList();

    var featureList = parsedJson['features_list'] as List;
    List<Feature> featureRaw =
        featureList.map((i) => Feature.fromJson(i)).toList();

    return Shop(
      support_phone: parsedJson['support_phone'],
      logo: FeaturedImage.fromJson(parsedJson['logo']),
      return_policy: parsedJson['return_policy'],
      privacy: parsedJson['privacy'],
      how_to_order: parsedJson['how_to_order'],
      faq: parsedJson['faq'],
      pay_methods_desc: parsedJson['pay_methods_desc'],
      word_hours: parsedJson['word_hours'],
      address: parsedJson['address'],
      social_media: SocialMedia.fromJson(parsedJson['social_media']),
      name: parsedJson['name'],
      subject: parsedJson['subject'],
      slug: parsedJson['slug'],
      phone: parsedJson['phone'],
      mobile: parsedJson['mobile'],
      about: parsedJson['about'],
      features_list: featureRaw,
      featured_image: FeaturedImage.fromJson(parsedJson['featured_image']),
      gallery: galleryRaw,
      policy: parsedJson['policy'],
    );
  }
}
