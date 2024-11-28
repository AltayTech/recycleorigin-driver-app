class SearchDetail {
  final int total;
  final int max_page;

  SearchDetail({
    required this.total,
    required this.max_page,
  });

  factory SearchDetail.fromJson(Map<String, dynamic> parsedJson) {
    return SearchDetail(
      total: parsedJson['total'],
      max_page: parsedJson['max_pages'],
    );
  }
}
