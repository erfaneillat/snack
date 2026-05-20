import 'package:flutter/foundation.dart';

enum EventCategory { entrepreneurship, art, skill, science }

enum EventStatusTone { open, upcoming, urgent }

enum EventVisualKind { video, content, finance, science, workshop }

@immutable
class EventItem {
  const EventItem({
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
    this.featured = false,
  });

  final int id;
  final String title;
  final String summary;
  final EventCategory category;
  final String typeLabel;
  final String statusLabel;
  final EventStatusTone statusTone;
  final DateTime registrationDeadline;
  final DateTime eventDate;
  final String feeLabel;
  final EventVisualKind visualKind;
  final bool featured;
}
