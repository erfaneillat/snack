import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/event_item_dto.dart';

class EventsRemoteDataSource {
  const EventsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<EventItemDto>> fetchEvents({
    required int page,
    required int pageSize,
    required int type,
  }) async {
    final response = await _dio.getUri<Object?>(
      AppConfig.eventsListUri(page: page, pageSize: pageSize, type: type),
      options: Options(followRedirects: false, validateStatus: (_) => true),
    );
    final data = response.data;

    if (response.statusCode != 200 || data == null) {
      throw StateError('Invalid events response: ${response.statusCode}');
    }

    final rawItems = _readItems(data);
    if (rawItems == null) {
      throw StateError('Invalid events response shape');
    }

    final events = <EventItemDto>[];
    for (final item in rawItems) {
      if (item is Map<String, dynamic>) {
        events.add(EventItemDto.fromJson(item));
        continue;
      }
      if (item is Map) {
        events.add(EventItemDto.fromJson(Map<String, dynamic>.from(item)));
        continue;
      }
      throw StateError('Invalid events item shape');
    }

    return events;
  }
}

List<Object?>? _readItems(Object? data) {
  if (data is List) {
    return data;
  }

  if (data is Map<String, dynamic>) {
    for (final key in ['items', 'data', 'result', 'results']) {
      final value = data[key];
      if (value is List) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final nestedItems = _readItems(value);
        if (nestedItems != null) {
          return nestedItems;
        }
      }
    }
  }

  return null;
}
