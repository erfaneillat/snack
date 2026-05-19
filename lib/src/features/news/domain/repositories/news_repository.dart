import '../entities/news_feed.dart';

abstract interface class NewsRepository {
  Future<NewsFeed> getNews({int page, int pageSize, int type});
}
