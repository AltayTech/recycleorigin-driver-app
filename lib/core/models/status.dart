import 'package:flutter/material.dart';

class Status with ChangeNotifier {
  final int term_id;
  final String name;
  final String slug;

  Status({required this.term_id, required this.name, required this.slug});

  factory Status.fromJson(Map<String, dynamic> parsedJson) {
    final dynamic tid = parsedJson['term_id'];
    var termId = 0;
    if (tid is int) {
      termId = tid;
    } else if (tid is num) {
      termId = tid.toInt();
    } else if (tid != null) {
      termId = int.tryParse(tid.toString()) ?? 0;
    }
    return Status(
      term_id: termId,
      name: parsedJson['name']?.toString() ?? '',
      slug: parsedJson['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term_id': term_id,
      'name': name,
      'slug': slug,
    };
  }
}
