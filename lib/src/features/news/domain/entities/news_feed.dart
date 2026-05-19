import 'package:flutter/foundation.dart';

import 'news_article.dart';

enum NewsSource { remote, fallback }

@immutable
class NewsFeed {
  const NewsFeed({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
    required this.loadedAt,
    this.source = NewsSource.remote,
    this.notice,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<NewsArticle> items;
  final DateTime loadedAt;
  final NewsSource source;
  final String? notice;

  bool get isFallback => source == NewsSource.fallback;
}
