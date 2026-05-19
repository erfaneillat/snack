import 'dart:convert';

import '../../domain/entities/news_feed.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/fallback_news_payload.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/news_feed_dto.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remoteDataSource);

  final NewsRemoteDataSource _remoteDataSource;

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    try {
      final dto = await _remoteDataSource.fetchNews(
        page: page,
        pageSize: pageSize,
        type: type,
      );
      return dto.toEntity(loadedAt: DateTime.now());
    } catch (_) {
      final fallback = NewsFeedDto.fromJson(
        jsonDecode(fallbackNewsPayload) as Map<String, dynamic>,
      );
      return fallback.toEntity(
        loadedAt: DateTime.now(),
        source: NewsSource.fallback,
        notice:
            'پاسخ زنده API در این محیط در دسترس نبود؛ داده نمونه مستندات نمایش داده شد.',
      );
    }
  }
}
