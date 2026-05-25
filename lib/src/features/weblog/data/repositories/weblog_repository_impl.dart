import '../../domain/entities/weblog_details.dart';
import '../../domain/entities/weblog_feed.dart';
import '../../domain/repositories/weblog_repository.dart';
import '../datasources/weblog_remote_data_source.dart';

class WeblogRepositoryImpl implements WeblogRepository {
  const WeblogRepositoryImpl(this._remoteDataSource);

  final WeblogRemoteDataSource _remoteDataSource;

  @override
  Future<WeblogFeed> getPosts({int page = 1, int pageSize = 20}) async {
    final dto = await _remoteDataSource.fetchPosts(
      page: page,
      pageSize: pageSize,
    );
    return dto.toEntity(loadedAt: DateTime.now());
  }

  @override
  Future<WeblogFeed> searchPosts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await _remoteDataSource.searchPosts(
      query: query,
      page: page,
      pageSize: pageSize,
    );
    return dto.toEntity(loadedAt: DateTime.now());
  }

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    final dto = await _remoteDataSource.fetchPostDetails(id: id);
    return dto.toEntity();
  }
}
