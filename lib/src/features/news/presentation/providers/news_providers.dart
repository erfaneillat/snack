import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_details.dart';
import '../../domain/entities/news_feed.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_news_details.dart';
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

final getNewsDetailsProvider = Provider<GetNewsDetails>((ref) {
  return GetNewsDetails(ref.watch(newsRepositoryProvider));
});

final newsDetailsProvider = FutureProvider.autoDispose.family<NewsDetails, int>(
  (ref, id) {
    return ref.watch(getNewsDetailsProvider).call(id);
  },
);

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
    if (current == null || _isLoadingNextPage || _hasReachedEnd) {
      return;
    }

    if (_isLastPage(current)) {
      _hasReachedEnd = true;
      return;
    }

    _isLoadingNextPage = true;
    try {
      final nextPage = await _fetchPage(current.page + 1);
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
        items: items,
      );

      _hasReachedEnd =
          _isLastPage(combinedFeed) ||
          newItems.length < AppConfig.defaultPageSize;
      state = AsyncData(combinedFeed);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isLoadingNextPage = false;
    }
  }

  Future<NewsFeed> _fetchPage(int page) {
    final query = ref.read(newsSearchQueryProvider).trim();
    return ref
        .read(getNewsFeedProvider)
        .call(
          page: page,
          pageSize: AppConfig.defaultPageSize,
          type: AppConfig.defaultNewsType,
          query: query,
        );
  }

  bool _isLastPage(NewsFeed feed) {
    return feed.items.isEmpty || feed.items.length >= feed.totalCount;
  }
}

final newsSearchQueryProvider =
    NotifierProvider.autoDispose<NewsSearchQueryNotifier, String>(
      NewsSearchQueryNotifier.new,
    );

class NewsSearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return '';
  }

  void setQuery(String value) {
    if (state == value) {
      return;
    }

    state = value;
    _scheduleFeedRefresh();
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }

    state = '';
    _refreshFeedNow();
  }

  void submit(String value) {
    if (state != value) {
      state = value;
    }
    _refreshFeedNow();
  }

  void _scheduleFeedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), _refreshFeedNow);
  }

  void _refreshFeedNow() {
    _debounceTimer?.cancel();
    ref.invalidate(newsFeedProvider);
  }
}

final selectedNewsTypeProvider =
    NotifierProvider.autoDispose<SelectedNewsTypeNotifier, int?>(
      SelectedNewsTypeNotifier.new,
    );

class SelectedNewsTypeNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? newsType) {
    state = newsType;
  }

  void clear() {
    state = null;
  }
}

final filteredNewsProvider = Provider.autoDispose<List<NewsArticle>>((ref) {
  final feed = ref.watch(newsFeedProvider).whenOrNull(data: (feed) => feed);
  if (feed == null) {
    return const [];
  }

  final selectedType = ref.watch(selectedNewsTypeProvider);
  Iterable<NewsArticle> items = feed.items;
  if (selectedType != null) {
    items = items.where((article) => article.newsType == selectedType);
  }

  return items.toList(growable: false);
});
