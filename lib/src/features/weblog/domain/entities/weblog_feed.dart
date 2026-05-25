import 'package:flutter/foundation.dart';

import 'weblog_post.dart';

@immutable
class WeblogFeed {
  const WeblogFeed({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
    required this.loadedAt,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<WeblogPost> items;
  final DateTime loadedAt;
}
