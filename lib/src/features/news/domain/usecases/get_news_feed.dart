import '../../../../core/config/app_config.dart';
import '../entities/news_feed.dart';
import '../repositories/news_repository.dart';

class GetNewsFeed {
  const GetNewsFeed(this._repository);

  final NewsRepository _repository;

  Future<NewsFeed> call({
    int page = AppConfig.defaultPage,
    int pageSize = AppConfig.defaultPageSize,
    int type = AppConfig.defaultNewsType,
  }) {
    return _repository.getNews(page: page, pageSize: pageSize, type: type);
  }
}
