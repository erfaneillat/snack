import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/news_details_dto.dart';
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
    return _readFeed(response);
  }

  Future<NewsFeedDto> searchNews({
    required String query,
    required int page,
    required int pageSize,
    required int type,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.newsSearchUri(
        query: query,
        page: page,
        pageSize: pageSize,
        type: type,
      ),
    );
    return _readFeed(response);
  }

  Future<NewsDetailsDto> fetchNewsDetails({required int id}) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.newsDetailsUri(id: id),
    );
    final data = response.data;

    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid news details response: ${response.statusCode}');
    }

    return NewsDetailsDto.fromJson(data);
  }

  NewsFeedDto _readFeed(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid news response: ${response.statusCode}');
    }

    return NewsFeedDto.fromJson(data);
  }
}
