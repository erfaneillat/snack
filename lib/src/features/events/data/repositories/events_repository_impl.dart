import '../../domain/entities/event_item.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_data_source.dart';

class EventsRepositoryImpl implements EventsRepository {
  const EventsRepositoryImpl(this._remoteDataSource);

  final EventsRemoteDataSource _remoteDataSource;

  @override
  Future<List<EventItem>> getEvents({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    final dtos = await _remoteDataSource.fetchEvents(
      page: page,
      pageSize: pageSize,
      type: type,
    );
    return [for (final dto in dtos) dto.toEntity()];
  }
}
