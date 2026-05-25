import 'package:flutter/foundation.dart';

enum CompetitionCategory {
  medical,
  language,
  technology,
  art,
  business,
  science,
  humanities,
}

enum CompetitionStatus {
  upcomingRegistration,
  registrationOpen,
  registrationClosed,
  running,
  ended,
  inactive,
}

@immutable
class CompetitionItem {
  const CompetitionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    this.amount,
    this.registrationStart,
    this.registrationDeadline,
    this.startDate,
    this.endDate,
    this.logoUrl,
    this.posterUrl,
    this.competitionUrl,
    this.category,
  });

  final int id;
  final String title;
  final String description;
  final bool isActive;
  final int? amount;
  final DateTime? registrationStart;
  final DateTime? registrationDeadline;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? logoUrl;
  final String? posterUrl;
  final String? competitionUrl;
  final CompetitionCategory? category;

  String? get imageUrl => posterUrl ?? logoUrl;

  bool get hasRegistrationLink => competitionUrl?.trim().isNotEmpty ?? false;

  bool get isFree => amount == null || amount! <= 0;

  CompetitionStatus statusAt(DateTime now) {
    if (!isActive) {
      return CompetitionStatus.inactive;
    }

    final registrationStartDate = registrationStart;
    if (registrationStartDate != null && now.isBefore(registrationStartDate)) {
      return CompetitionStatus.upcomingRegistration;
    }

    final registrationDeadlineDate = registrationDeadline;
    if (registrationDeadlineDate != null &&
        now.isBefore(_endOfDay(registrationDeadlineDate))) {
      return CompetitionStatus.registrationOpen;
    }

    final eventStartDate = startDate;
    if (eventStartDate != null && now.isBefore(eventStartDate)) {
      return CompetitionStatus.registrationClosed;
    }

    final eventEndDate = endDate;
    if (eventEndDate != null && now.isBefore(_endOfDay(eventEndDate))) {
      return CompetitionStatus.running;
    }

    return CompetitionStatus.ended;
  }
}

DateTime _endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
