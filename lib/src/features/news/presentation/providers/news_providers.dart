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

final newsFeedProvider = AsyncNotifierProvider<NewsFeedNotifier, NewsFeed>(
  NewsFeedNotifier.new,
);

class NewsFeedNotifier extends AsyncNotifier<NewsFeed> {
  bool _isLoadingNextPage = false;
  bool _hasReachedEnd = false;

  @override
  Future<NewsFeed> build() async {
    _hasReachedEnd = false;
    final feed = await _fetchPage(AppConfig.defaultPage);
    _hasReachedEnd = _isLastPage(feed);
    return feed;
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null ||
        _isLoadingNextPage ||
        _hasReachedEnd ||
        current.isFallback) {
      return;
    }

    if (_isLastPage(current)) {
      _hasReachedEnd = true;
      return;
    }

    _isLoadingNextPage = true;
    try {
      final nextPage = await _fetchPage(current.page + 1);
      if (nextPage.isFallback) {
        _hasReachedEnd = true;
        return;
      }

      final existingIds = {for (final article in current.items) article.id};
      final newItems = [
        for (final article in nextPage.items)
          if (!existingIds.contains(article.id)) article,
      ];

      if (newItems.isEmpty) {
        _hasReachedEnd = true;
        return;
      }

      final items = [...current.items, ...newItems];
      final combinedFeed = NewsFeed(
        page: nextPage.page,
        pageSize: nextPage.pageSize,
        totalCount: nextPage.totalCount,
        loadedAt: nextPage.loadedAt,
        source: nextPage.source,
        notice: nextPage.notice ?? current.notice,
        items: items,
      );

      _hasReachedEnd =
          _isLastPage(combinedFeed) ||
          newItems.length < AppConfig.defaultPageSize;
      state = AsyncData(combinedFeed);
    } finally {
      _isLoadingNextPage = false;
    }
  }

  Future<NewsFeed> _fetchPage(int page) {
    return ref
        .read(getNewsFeedProvider)
        .call(
          page: page,
          pageSize: AppConfig.defaultPageSize,
          type: AppConfig.defaultNewsType,
        );
  }

  bool _isLastPage(NewsFeed feed) {
    return feed.isFallback ||
        feed.items.isEmpty ||
        feed.items.length >= feed.totalCount;
  }
}

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
