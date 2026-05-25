import '../../domain/entities/weblog_feed.dart';
import 'weblog_post_dto.dart';

class WeblogFeedDto {
  const WeblogFeedDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<WeblogPostDto> items;

  factory WeblogFeedDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return WeblogFeedDto(
      page: _readInt(json['page']) ?? 1,
      pageSize: _readInt(json['pageSize']) ?? 20,
      totalCount: _readInt(json['totalCount']) ?? 0,
      items: rawItems is List
          ? [for (final item in rawItems) ?_postFromRawItem(item)]
          : const [],
    );
  }

  WeblogFeed toEntity({required DateTime loadedAt}) {
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      loadedAt: loadedAt,
      items: [for (final item in items) item.toEntity()],
    );
  }
}

WeblogPostDto? _postFromRawItem(Object? item) {
  if (item is Map<String, dynamic>) {
    return WeblogPostDto.fromJson(item);
  }
  if (item is Map) {
    return WeblogPostDto.fromJson(Map<String, dynamic>.from(item));
  }
  return null;
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
