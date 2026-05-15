class Sizes {
  const Sizes({
    this.thumbnail = '',
    this.medium = '',
    this.large = '',
  });

  final String thumbnail;
  final String medium;
  final String large;

  factory Sizes.fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) {
      return Sizes(thumbnail: '', medium: '', large: '');
    }
    return Sizes(
      thumbnail: parsedJson['thumbnail'] as String? ?? '',
      medium: parsedJson['medium'] as String? ?? '',
      large: parsedJson['large'] as String? ?? '',
    );
  }
}
