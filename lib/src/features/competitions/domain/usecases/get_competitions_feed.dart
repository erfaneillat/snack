import '../../../../core/config/app_config.dart';
import '../entities/competition_feed.dart';
import '../repositories/competitions_repository.dart';

class GetCompetitionsFeed {
  const GetCompetitionsFeed(this._repository);

  final CompetitionsRepository _repository;

  Future<CompetitionFeed> call({
    int page = AppConfig.defaultPage,
    int pageSize = AppConfig.defaultPageSize,
    bool onlyActive = true,
  }) {
    return _repository.getCompetitions(
      page: page,
      pageSize: pageSize,
      onlyActive: onlyActive,
    );
  }
}
