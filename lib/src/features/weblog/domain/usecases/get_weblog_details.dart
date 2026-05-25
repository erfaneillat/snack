import '../entities/weblog_details.dart';
import '../repositories/weblog_repository.dart';

class GetWeblogDetails {
  const GetWeblogDetails(this._repository);

  final WeblogRepository _repository;

  Future<WeblogDetails> call(int id) {
    return _repository.getPostDetails(id: id);
  }
}
