import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/news_feed_dto.dart';

class NewsRemoteDataSource {
  const NewsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NewsFeedDto> fetchNews({
    required int page,
    required int pageSize,
    required int type,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.newsListUri(page: page, pageSize: pageSize, type: type),
    );
    final data = response.data;

    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid news response: ${response.statusCode}');
    }

    return NewsFeedDto.fromJson(data);
  }
}
