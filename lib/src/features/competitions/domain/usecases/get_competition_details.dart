import '../entities/competition_details.dart';
import '../repositories/competitions_repository.dart';

class GetCompetitionDetails {
  const GetCompetitionDetails(this._repository);

  final CompetitionsRepository _repository;

  Future<CompetitionDetails> call(int id) {
    return _repository.getCompetitionDetails(id: id);
  }
}
