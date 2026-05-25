import '../entities/weblog_feed.dart';
import '../entities/weblog_details.dart';

abstract interface class WeblogRepository {
  Future<WeblogFeed> getPosts({int page, int pageSize});

  Future<WeblogFeed> searchPosts({
    required String query,
    int page,
    int pageSize,
  });

  Future<WeblogDetails> getPostDetails({required int id});
}
