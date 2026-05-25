import '../../domain/entities/competition_details.dart';
import '../../domain/entities/competition_feed.dart';
import '../../domain/repositories/competitions_repository.dart';
import '../datasources/competitions_remote_data_source.dart';

class CompetitionsRepositoryImpl implements CompetitionsRepository {
  const CompetitionsRepositoryImpl(this._remoteDataSource);

  final CompetitionsRemoteDataSource _remoteDataSource;

  @override
  Future<CompetitionFeed> getCompetitions({
    int page = 1,
    int pageSize = 20,
    bool onlyActive = true,
  }) async {
    final dto = await _remoteDataSource.fetchCompetitions(
      page: page,
      pageSize: pageSize,
      onlyActive: onlyActive,
    );
    return dto.toEntity(loadedAt: DateTime.now());
  }

  @override
  Future<CompetitionDetails> getCompetitionDetails({required int id}) async {
    final dto = await _remoteDataSource.fetchCompetitionDetails(id: id);
    return dto.toEntity();
  }
}
