import 'package:flutter/foundation.dart';

import 'news_article.dart';

@immutable
class NewsFeed {
  const NewsFeed({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
    required this.loadedAt,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<NewsArticle> items;
  final DateTime loadedAt;
}
