import '../../domain/entities/event_item.dart';

class EventItemDto {
  const EventItemDto({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.typeLabel,
    required this.statusLabel,
    required this.statusTone,
    required this.registrationDeadline,
    required this.eventDate,
    required this.feeLabel,
    required this.visualKind,
    required this.featured,
  });

  final int? id;
  final String title;
  final String summary;
  final EventCategory? category;
  final String typeLabel;
  final String statusLabel;
  final EventStatusTone statusTone;
  final DateTime? registrationDeadline;
  final DateTime? eventDate;
  final String feeLabel;
  final EventVisualKind visualKind;
  final bool featured;

  factory EventItemDto.fromJson(Map<String, dynamic> json) {
    final title = _readString(
      json['title'] ?? json['name'] ?? json['eventTitle'],
    );
    if (title.isEmpty) {
      throw const FormatException('Event item is missing a title');
    }

    final categoryText = _readString(
      json['category'] ?? json['categoryTitle'] ?? json['categoryName'],
    );
    final typeLabel = _readString(json['typeLabel'] ?? json['type']);
    final statusLabel = _readString(json['statusLabel'] ?? json['status']);
    final descriptor = '$title $categoryText $typeLabel $statusLabel';

    return EventItemDto(
      id: _readInt(json['id'] ?? json['eventId']),
      title: title,
      summary: _readString(
        json['summary'] ?? json['description'] ?? json['shortDescription'],
      ),
      category: _readCategory(descriptor),
      typeLabel: typeLabel,
      statusLabel: statusLabel,
      statusTone: _readStatusTone(statusLabel),
      registrationDeadline: _readDate(
        json['registrationDeadline'] ??
            json['registerDeadline'] ??
            json['deadline'],
      ),
      eventDate: _readDate(
        json['eventDate'] ?? json['startDate'] ?? json['date'],
      ),
      feeLabel: _readString(json['feeLabel'] ?? json['fee'] ?? json['price']),
      visualKind: _readVisualKind(descriptor),
      featured: _readBool(json['featured'] ?? json['isFeatured']),
    );
  }

  EventItem toEntity() {
    return EventItem(
      id: id,
      title: title,
      summary: summary,
      category: category,
      typeLabel: typeLabel,
      statusLabel: statusLabel,
      statusTone: statusTone,
      registrationDeadline: registrationDeadline,
      eventDate: eventDate,
      feeLabel: feeLabel,
      visualKind: visualKind,
      featured: featured,
    );
  }
}

String _readString(Object? value) {
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

DateTime? _readDate(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }
  return null;
}

EventCategory? _readCategory(String value) {
  final text = _normalize(value);
  if (text.contains('کارآفرین') || text.contains('کسب و کار')) {
    return EventCategory.entrepreneurship;
  }
  if (text.contains('هنر') || text.contains('پوستر')) {
    return EventCategory.art;
  }
  if (text.contains('علم') ||
      text.contains('پژوهش') ||
      text.contains('میکروبیولوژی')) {
    return EventCategory.science;
  }
  if (text.contains('مهارت') ||
      text.contains('مسابقه') ||
      text.contains('رقابت') ||
      text.contains('چالش')) {
    return EventCategory.skill;
  }
  return null;
}

EventStatusTone _readStatusTone(String value) {
  final text = _normalize(value);
  if (text.contains('محدود') || text.contains('فوری')) {
    return EventStatusTone.urgent;
  }
  if (text.contains('زودی') || text.contains('آینده')) {
    return EventStatusTone.upcoming;
  }
  return EventStatusTone.open;
}

EventVisualKind _readVisualKind(String value) {
  final text = _normalize(value);
  if (text.contains('ویدیو') || text.contains('کلیپ')) {
    return EventVisualKind.video;
  }
  if (text.contains('محتوا') || text.contains('پوستر')) {
    return EventVisualKind.content;
  }
  if (text.contains('حساب') || text.contains('مالی')) {
    return EventVisualKind.finance;
  }
  if (text.contains('علم') ||
      text.contains('زیست') ||
      text.contains('میکروبیولوژی')) {
    return EventVisualKind.science;
  }
  if (text.contains('کارگاه') ||
      text.contains('وبینار') ||
      text.contains('کارآفرین')) {
    return EventVisualKind.workshop;
  }
  return EventVisualKind.generic;
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
