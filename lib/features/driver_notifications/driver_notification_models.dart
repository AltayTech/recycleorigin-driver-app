class DriverNotificationItem {
  DriverNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.readAt,
    this.deepLink,
  });

  final int id;
  final String title;
  final String body;
  final String category;
  final String createdAt;
  final String? readAt;
  final String? deepLink;

  factory DriverNotificationItem.fromJson(Map<String, dynamic> j) {
    return DriverNotificationItem(
      id: int.tryParse('${j['id'] ?? j['ID'] ?? 0}') ?? 0,
      title: j['title'] as String? ?? j['Title'] as String? ?? '',
      body: j['body'] as String? ?? j['Body'] as String? ?? '',
      category: j['category'] as String? ?? j['Category'] as String? ?? '',
      createdAt:
          j['created_at']?.toString() ?? j['CreatedAt']?.toString() ?? '',
      readAt: j['read_at']?.toString() ?? j['ReadAt']?.toString(),
      deepLink: j['deep_link'] as String? ?? j['DeepLink'] as String?,
    );
  }

  bool get isRead => readAt != null && readAt!.isNotEmpty;
}
