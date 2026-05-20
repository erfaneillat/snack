import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event_catalog.dart';
import '../../domain/entities/event_item.dart';

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

final featuredEventsProvider = Provider.autoDispose<List<EventItem>>((ref) {
  return eventCatalog.where((event) => event.featured).toList(growable: false);
});

final filteredEventsProvider = Provider.autoDispose<List<EventItem>>((ref) {
  final selectedCategory = ref.watch(selectedEventCategoryProvider);
  final query = _normalize(ref.watch(eventSearchQueryProvider));

  return eventCatalog
      .where((event) => !event.featured)
      .where((event) {
        if (selectedCategory != null && event.category != selectedCategory) {
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

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
