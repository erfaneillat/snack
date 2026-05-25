import '../../../../core/config/app_config.dart';
import '../entities/weblog_feed.dart';
import '../repositories/weblog_repository.dart';

class GetWeblogFeed {
  const GetWeblogFeed(this._repository);

  final WeblogRepository _repository;

  Future<WeblogFeed> call({
    int page = AppConfig.defaultPage,
    int pageSize = AppConfig.defaultPageSize,
    String query = '',
  }) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isNotEmpty) {
      return _repository.searchPosts(
        query: normalizedQuery,
        page: page,
        pageSize: pageSize,
      );
    }

    return _repository.getPosts(page: page, pageSize: pageSize);
  }
}
