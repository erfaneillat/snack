import '../../domain/entities/competition_feed.dart';
import 'competition_item_dto.dart';

class CompetitionFeedDto {
  const CompetitionFeedDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<CompetitionItemDto> items;

  factory CompetitionFeedDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return CompetitionFeedDto(
      page: _readInt(json['page']) ?? 1,
      pageSize: _readInt(json['pageSize']) ?? 20,
      totalCount: _readInt(json['totalCount']) ?? 0,
      items: rawItems is List
          ? [for (final item in rawItems) ?_competitionFromRawItem(item)]
          : const [],
    );
  }

  CompetitionFeed toEntity({required DateTime loadedAt}) {
    return CompetitionFeed(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      loadedAt: loadedAt,
      items: [for (final item in items) item.toEntity()],
    );
  }
}

CompetitionItemDto? _competitionFromRawItem(Object? item) {
  if (item is Map<String, dynamic>) {
    return CompetitionItemDto.fromJson(item);
  }
  if (item is Map) {
    return CompetitionItemDto.fromJson(Map<String, dynamic>.from(item));
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
