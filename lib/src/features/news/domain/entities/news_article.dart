import 'package:flutter/foundation.dart';

@immutable
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.publishDate,
    required this.linkCode,
    required this.newsType,
    this.summary,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final DateTime? publishDate;
  final String linkCode;
  final int newsType;
}
