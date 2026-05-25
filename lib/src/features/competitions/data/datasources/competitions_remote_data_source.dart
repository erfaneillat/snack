import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/competition_details_dto.dart';
import '../models/competition_feed_dto.dart';

class CompetitionsRemoteDataSource {
  const CompetitionsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CompetitionFeedDto> fetchCompetitions({
    required int page,
    required int pageSize,
    required bool onlyActive,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.competitionListUri(
        page: page,
        pageSize: pageSize,
        onlyActive: onlyActive,
      ),
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid competitions response: ${response.statusCode}');
    }

    return CompetitionFeedDto.fromJson(data);
  }

  Future<CompetitionDetailsDto> fetchCompetitionDetails({
    required int id,
  }) async {
    final response = await _dio.getUri<Map<String, dynamic>>(
      AppConfig.competitionDetailsUri(id: id),
    );
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw StateError(
        'Invalid competition details response: ${response.statusCode}',
      );
    }

    return CompetitionDetailsDto.fromJson(data);
  }
}
