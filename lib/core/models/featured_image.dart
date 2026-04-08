import 'package:recycleorigindriver/core/models/sizes.dart';

class FeaturedImage {
  final int id;
  final String title;
  final Sizes sizes;

  FeaturedImage({required this.id, required this.title, required this.sizes});

  factory FeaturedImage.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return FeaturedImage(id: 0, title: '', sizes: const Sizes());
    }
    final parsedJson = raw;
    final rawSizes = parsedJson['sizes'];
    return FeaturedImage(
      id: parsedJson['id'] is int
          ? parsedJson['id'] as int
          : int.tryParse('${parsedJson['id']}') ?? 0,
      title: parsedJson['title'] as String? ?? '',
      sizes: rawSizes is Map<String, dynamic>
          ? Sizes.fromJson(rawSizes)
          : const Sizes(),
    );
  }
}
