import '../../domain/entities/news_feed.dart';
import 'news_article_dto.dart';

class NewsFeedDto {
  const NewsFeedDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<NewsArticleDto> items;

  factory NewsFeedDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return NewsFeedDto(
      page: _readInt(json['page']) ?? 1,
      pageSize: _readInt(json['pageSize']) ?? 20,
      totalCount: _readInt(json['totalCount']) ?? 0,
      items: rawItems is List
          ? [
              for (final item in rawItems)
                if (item is Map<String, dynamic>) NewsArticleDto.fromJson(item),
            ]
          : const [],
    );
  }

  NewsFeed toEntity({required DateTime loadedAt}) {
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      loadedAt: loadedAt,
      items: [for (final item in items) item.toEntity()],
    );
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
