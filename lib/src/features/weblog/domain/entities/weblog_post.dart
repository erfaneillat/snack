import 'package:flutter/foundation.dart';

@immutable
class WeblogPost {
  const WeblogPost({
    required this.id,
    required this.title,
    required this.linkCode,
    this.summary,
    this.imageUrl,
    this.author,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final String? author;
  final DateTime? createdAt;
  final String linkCode;
}
