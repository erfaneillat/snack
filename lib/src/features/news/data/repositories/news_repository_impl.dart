import '../../domain/entities/news_details.dart';
import '../../domain/entities/news_feed.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remoteDataSource);

  final NewsRemoteDataSource _remoteDataSource;

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    final dto = await _remoteDataSource.fetchNews(
      page: page,
      pageSize: pageSize,
      type: type,
    );
    return dto.toEntity(loadedAt: DateTime.now());
  }

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    final dto = await _remoteDataSource.searchNews(
      query: query,
      page: page,
      pageSize: pageSize,
      type: type,
    );
    return dto.toEntity(loadedAt: DateTime.now());
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    final dto = await _remoteDataSource.fetchNewsDetails(id: id);
    return dto.toEntity();
  }
}
