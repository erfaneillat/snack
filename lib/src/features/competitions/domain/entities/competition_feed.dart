import 'package:flutter/foundation.dart';

import 'competition_item.dart';

@immutable
class CompetitionFeed {
  const CompetitionFeed({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
    required this.loadedAt,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<CompetitionItem> items;
  final DateTime loadedAt;
}
