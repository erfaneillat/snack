import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/weblog_remote_data_source.dart';
import '../../data/repositories/weblog_repository_impl.dart';
import '../../domain/entities/weblog_details.dart';
import '../../domain/entities/weblog_feed.dart';
import '../../domain/entities/weblog_post.dart';
import '../../domain/repositories/weblog_repository.dart';
import '../../domain/usecases/get_weblog_details.dart';
import '../../domain/usecases/get_weblog_feed.dart';

final weblogRemoteDataSourceProvider = Provider<WeblogRemoteDataSource>((ref) {
  return WeblogRemoteDataSource(ref.watch(dioProvider));
});

final weblogRepositoryProvider = Provider<WeblogRepository>((ref) {
  return WeblogRepositoryImpl(ref.watch(weblogRemoteDataSourceProvider));
});

final getWeblogFeedProvider = Provider<GetWeblogFeed>((ref) {
  return GetWeblogFeed(ref.watch(weblogRepositoryProvider));
});

final getWeblogDetailsProvider = Provider<GetWeblogDetails>((ref) {
  return GetWeblogDetails(ref.watch(weblogRepositoryProvider));
});

final weblogDetailsProvider = FutureProvider.autoDispose
    .family<WeblogDetails, int>((ref, id) {
      return ref.watch(getWeblogDetailsProvider).call(id);
    });

final weblogFeedProvider =
    AsyncNotifierProvider<WeblogFeedNotifier, WeblogFeed>(
      WeblogFeedNotifier.new,
    );

class WeblogFeedNotifier extends AsyncNotifier<WeblogFeed> {
  bool _isLoadingNextPage = false;
  bool _hasReachedEnd = false;

  @override
  Future<WeblogFeed> build() async {
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
      final existingIds = {for (final post in current.items) post.id};
      final newItems = [
        for (final post in nextPage.items)
          if (!existingIds.contains(post.id)) post,
      ];

      if (newItems.isEmpty) {
        _hasReachedEnd = true;
        return;
      }

      final items = [...current.items, ...newItems];
      final combinedFeed = WeblogFeed(
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

  Future<WeblogFeed> _fetchPage(int page) {
    final query = ref.read(weblogSearchQueryProvider).trim();
    return ref
        .read(getWeblogFeedProvider)
        .call(page: page, pageSize: AppConfig.defaultPageSize, query: query);
  }

  bool _isLastPage(WeblogFeed feed) {
    return feed.items.isEmpty || feed.items.length >= feed.totalCount;
  }
}

final weblogSearchQueryProvider =
    NotifierProvider.autoDispose<WeblogSearchQueryNotifier, String>(
      WeblogSearchQueryNotifier.new,
    );

class WeblogSearchQueryNotifier extends Notifier<String> {
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
    ref.invalidate(weblogFeedProvider);
  }
}

final filteredWeblogPostsProvider = Provider.autoDispose<List<WeblogPost>>((
  ref,
) {
  final feed = ref.watch(weblogFeedProvider).whenOrNull(data: (feed) => feed);
  if (feed == null) {
    return const [];
  }

  return feed.items;
});

String normalizeWeblogText(String value) => _normalize(value);

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
