import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/events_remote_data_source.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../domain/entities/event_item.dart';
import '../../domain/repositories/events_repository.dart';

final eventsRemoteDataSourceProvider = Provider<EventsRemoteDataSource>((ref) {
  return EventsRemoteDataSource(ref.watch(dioProvider));
});

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(ref.watch(eventsRemoteDataSourceProvider));
});

final eventItemsProvider = FutureProvider.autoDispose<List<EventItem>>((ref) {
  return ref
      .watch(eventsRepositoryProvider)
      .getEvents(
        page: AppConfig.defaultPage,
        pageSize: AppConfig.defaultPageSize,
        type: AppConfig.defaultEventsType,
      );
});

final eventSearchQueryProvider =
    NotifierProvider.autoDispose<EventSearchQueryNotifier, String>(
      EventSearchQueryNotifier.new,
    );

class EventSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final selectedEventCategoryProvider =
    NotifierProvider.autoDispose<EventCategoryNotifier, EventCategory?>(
      EventCategoryNotifier.new,
    );

class EventCategoryNotifier extends Notifier<EventCategory?> {
  @override
  EventCategory? build() => null;

  void select(EventCategory? category) {
    state = category;
  }
}

final featuredEventIndexProvider =
    NotifierProvider.autoDispose<FeaturedEventIndexNotifier, int>(
      FeaturedEventIndexNotifier.new,
    );

class FeaturedEventIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final featuredEventsProvider =
    Provider.autoDispose<AsyncValue<List<EventItem>>>((ref) {
      return ref.watch(eventItemsProvider).whenData((events) {
        return events.where((event) => event.featured).toList(growable: false);
      });
    });

final filteredEventsProvider =
    Provider.autoDispose<AsyncValue<List<EventItem>>>((ref) {
      final selectedCategory = ref.watch(selectedEventCategoryProvider);
      final query = _normalize(ref.watch(eventSearchQueryProvider));

      return ref.watch(eventItemsProvider).whenData((events) {
        return events
            .where((event) => !event.featured)
            .where((event) {
              if (selectedCategory != null &&
                  event.category != selectedCategory) {
                return false;
              }

              if (query.isEmpty) {
                return true;
              }

              final haystack = _normalize(
                '${event.title} ${event.summary} ${event.typeLabel} '
                '${event.statusLabel} ${event.feeLabel}',
              );
              return haystack.contains(query);
            })
            .toList(growable: false);
      });
    });

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
