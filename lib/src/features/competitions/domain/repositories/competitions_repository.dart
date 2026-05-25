import '../entities/competition_details.dart';
import '../entities/competition_feed.dart';

abstract interface class CompetitionsRepository {
  Future<CompetitionFeed> getCompetitions({
    int page,
    int pageSize,
    bool onlyActive,
  });

  Future<CompetitionDetails> getCompetitionDetails({required int id});
}
