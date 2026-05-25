import 'package:flutter/foundation.dart';

@immutable
class WeblogDetails {
  const WeblogDetails({
    required this.id,
    required this.title,
    required this.bodyHtml,
    required this.linkCode,
    this.metaDescription,
    this.keywords,
    this.author,
    this.imageUrl,
    this.tags,
    this.createdAt,
  });

  final int id;
  final String title;
  final String bodyHtml;
  final String? metaDescription;
  final String? keywords;
  final String? author;
  final String? imageUrl;
  final String? tags;
  final String linkCode;
  final DateTime? createdAt;
}
