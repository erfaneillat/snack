import '../entities/news_details.dart';
import '../repositories/news_repository.dart';

class GetNewsDetails {
  const GetNewsDetails(this._repository);

  final NewsRepository _repository;

  Future<NewsDetails> call(int id) {
    return _repository.getNewsDetails(id: id);
  }
}
