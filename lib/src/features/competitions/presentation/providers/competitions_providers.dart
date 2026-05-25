import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/competitions_remote_data_source.dart';
import '../../data/repositories/competitions_repository_impl.dart';
import '../../domain/entities/competition_details.dart';
import '../../domain/entities/competition_feed.dart';
import '../../domain/entities/competition_item.dart';
import '../../domain/repositories/competitions_repository.dart';
import '../../domain/usecases/get_competition_details.dart';
import '../../domain/usecases/get_competitions_feed.dart';

enum CompetitionQuickFilter {
  all,
  registrationOpen,
  free,
  withRegistrationLink,
}

final competitionsRemoteDataSourceProvider =
    Provider<CompetitionsRemoteDataSource>((ref) {
      return CompetitionsRemoteDataSource(ref.watch(dioProvider));
    });

final competitionsRepositoryProvider = Provider<CompetitionsRepository>((ref) {
  return CompetitionsRepositoryImpl(
    ref.watch(competitionsRemoteDataSourceProvider),
  );
});

final getCompetitionsFeedProvider = Provider<GetCompetitionsFeed>((ref) {
  return GetCompetitionsFeed(ref.watch(competitionsRepositoryProvider));
});

final getCompetitionDetailsProvider = Provider<GetCompetitionDetails>((ref) {
  return GetCompetitionDetails(ref.watch(competitionsRepositoryProvider));
});

final competitionDetailsProvider = FutureProvider.autoDispose
    .family<CompetitionDetails, int>((ref, id) {
      return ref.watch(getCompetitionDetailsProvider).call(id);
    });

final competitionsFeedProvider =
    AsyncNotifierProvider<CompetitionsFeedNotifier, CompetitionFeed>(
      CompetitionsFeedNotifier.new,
    );

class CompetitionsFeedNotifier extends AsyncNotifier<CompetitionFeed> {
  bool _isLoadingNextPage = false;
  bool _hasReachedEnd = false;

  @override
  Future<CompetitionFeed> build() async {
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
      final existingIds = {for (final item in current.items) item.id};
      final newItems = [
        for (final item in nextPage.items)
          if (!existingIds.contains(item.id)) item,
      ];

      if (newItems.isEmpty) {
        _hasReachedEnd = true;
        return;
      }

      final items = [...current.items, ...newItems];
      final combinedFeed = CompetitionFeed(
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

  Future<CompetitionFeed> _fetchPage(int page) {
    return ref
        .read(getCompetitionsFeedProvider)
        .call(page: page, pageSize: AppConfig.defaultPageSize);
  }

  bool _isLastPage(CompetitionFeed feed) {
    return feed.items.isEmpty || feed.items.length >= feed.totalCount;
  }
}

final competitionSearchQueryProvider =
    NotifierProvider.autoDispose<CompetitionSearchQueryNotifier, String>(
      CompetitionSearchQueryNotifier.new,
    );

class CompetitionSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final selectedCompetitionFilterProvider =
    NotifierProvider.autoDispose<
      SelectedCompetitionFilterNotifier,
      CompetitionQuickFilter
    >(SelectedCompetitionFilterNotifier.new);

class SelectedCompetitionFilterNotifier
    extends Notifier<CompetitionQuickFilter> {
  @override
  CompetitionQuickFilter build() => CompetitionQuickFilter.all;

  void select(CompetitionQuickFilter filter) {
    state = filter;
  }

  void clear() {
    state = CompetitionQuickFilter.all;
  }
}

final filteredCompetitionsProvider =
    Provider.autoDispose<List<CompetitionItem>>((ref) {
      final feed = ref
          .watch(competitionsFeedProvider)
          .whenOrNull(data: (feed) => feed);
      if (feed == null) {
        return const [];
      }

      final query = normalizeCompetitionText(
        ref.watch(competitionSearchQueryProvider),
      );
      final selectedFilter = ref.watch(selectedCompetitionFilterProvider);
      final now = DateTime.now();

      return feed.items
          .where((item) {
            if (query.isNotEmpty) {
              final haystack = normalizeCompetitionText(
                '${item.title} ${item.description} '
                '${competitionCategoryLabel(item.category)} '
                '${competitionStatusLabel(item.statusAt(now))}',
              );
              if (!haystack.contains(query)) {
                return false;
              }
            }

            return switch (selectedFilter) {
              CompetitionQuickFilter.all => true,
              CompetitionQuickFilter.registrationOpen =>
                item.statusAt(now) == CompetitionStatus.registrationOpen,
              CompetitionQuickFilter.free => item.isFree,
              CompetitionQuickFilter.withRegistrationLink =>
                item.hasRegistrationLink,
            };
          })
          .toList(growable: false);
    });

String competitionStatusLabel(CompetitionStatus status) {
  return switch (status) {
    CompetitionStatus.upcomingRegistration => 'ثبت‌نام به‌زودی',
    CompetitionStatus.registrationOpen => 'ثبت‌نام باز',
    CompetitionStatus.registrationClosed => 'ثبت‌نام بسته',
    CompetitionStatus.running => 'در حال برگزاری',
    CompetitionStatus.ended => 'پایان یافته',
    CompetitionStatus.inactive => 'غیرفعال',
  };
}

String competitionCategoryLabel(CompetitionCategory? category) {
  return switch (category) {
    CompetitionCategory.medical => 'علوم پزشکی',
    CompetitionCategory.language => 'زبان و ترجمه',
    CompetitionCategory.technology => 'فناوری',
    CompetitionCategory.art => 'هنر و محتوا',
    CompetitionCategory.business => 'کسب‌وکار',
    CompetitionCategory.science => 'علمی پژوهشی',
    CompetitionCategory.humanities => 'علوم انسانی',
    null => 'عمومی',
  };
}

String normalizeCompetitionText(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
