import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_feed.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_news_feed.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSource(ref.watch(dioProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(ref.watch(newsRemoteDataSourceProvider));
});

final getNewsFeedProvider = Provider<GetNewsFeed>((ref) {
  return GetNewsFeed(ref.watch(newsRepositoryProvider));
});

final newsFeedProvider = FutureProvider<NewsFeed>((ref) {
  return ref
      .watch(getNewsFeedProvider)
      .call(
        page: AppConfig.defaultPage,
        pageSize: AppConfig.defaultPageSize,
        type: AppConfig.defaultNewsType,
      );
});

final newsSearchQueryProvider =
    NotifierProvider.autoDispose<NewsSearchQueryNotifier, String>(
      NewsSearchQueryNotifier.new,
    );

class NewsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final filteredNewsProvider = Provider.autoDispose<List<NewsArticle>>((ref) {
  final feed = ref.watch(newsFeedProvider).whenOrNull(data: (feed) => feed);
  if (feed == null) {
    return const [];
  }

  final query = ref.watch(newsSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) {
    return feed.items;
  }

  return feed.items
      .where((article) {
        final haystack =
            '${article.title} ${article.summary ?? ''} ${article.linkCode}'
                .toLowerCase();
        return haystack.contains(query);
      })
      .toList(growable: false);
});
