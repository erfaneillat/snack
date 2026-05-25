import '../entities/event_item.dart';

abstract interface class EventsRepository {
  Future<List<EventItem>> getEvents({int page, int pageSize, int type});
}
