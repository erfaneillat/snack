import '../entities/news_details.dart';
import '../entities/news_feed.dart';

abstract interface class NewsRepository {
  Future<NewsFeed> getNews({int page, int pageSize, int type});

  Future<NewsFeed> searchNews({
    required String query,
    int page,
    int pageSize,
    int type,
  });

  Future<NewsDetails> getNewsDetails({required int id});
}
