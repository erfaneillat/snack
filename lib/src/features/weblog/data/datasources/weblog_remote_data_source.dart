import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/weblog_details_dto.dart';
import '../models/weblog_feed_dto.dart';

class WeblogRemoteDataSource {
  const WeblogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<WeblogFeedDto> fetchPosts({
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.weblogListUri(page: page, pageSize: pageSize),
    );
    return _readFeed(response);
  }

  Future<WeblogFeedDto> searchPosts({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.weblogSearchUri(query: query, page: page, pageSize: pageSize),
    );
    return _readFeed(response);
  }

  WeblogFeedDto _readFeed(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid weblog response: ${response.statusCode}');
    }

    return WeblogFeedDto.fromJson(data);
  }

  Future<WeblogDetailsDto> fetchPostDetails({required int id}) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.weblogDetailsUri(id: id),
    );
    final data = response.data;

    if (response.statusCode != 200 || data == null) {
      throw StateError(
        'Invalid weblog details response: ${response.statusCode}',
      );
    }

    return WeblogDetailsDto.fromJson(data);
  }
}
