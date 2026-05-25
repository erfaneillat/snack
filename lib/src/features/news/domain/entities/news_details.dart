import 'package:flutter/foundation.dart';

@immutable
class NewsDetails {
  const NewsDetails({
    required this.id,
    required this.title,
    required this.bodyHtml,
    required this.linkCode,
    required this.newsType,
    required this.visitCount,
    this.summary,
    this.metaDescription,
    this.tags,
    this.imageUrl,
    this.publishDate,
    this.recordUpdate,
  });

  final int id;
  final String title;
  final String bodyHtml;
  final String? summary;
  final String? metaDescription;
  final String? tags;
  final String? imageUrl;
  final DateTime? publishDate;
  final String linkCode;
  final int newsType;
  final int visitCount;
  final DateTime? recordUpdate;
}
