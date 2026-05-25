import 'package:flutter/foundation.dart';

import 'competition_item.dart';

@immutable
class CompetitionDetails {
  const CompetitionDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    this.amount,
    this.themes = const [],
    this.edition,
    this.maxTeamMembers,
    this.minTeamMembers,
    this.registrationStart,
    this.registrationDeadline,
    this.startDate,
    this.endDate,
    this.scientificCommittee = const [],
    this.executiveCommittee = const [],
    this.secretariatAddress,
    this.secretariatPhone,
    this.logoUrl,
    this.posterUrl,
    this.landscapeUrl,
    this.beneficiaries,
    this.sponsors = const [],
    this.summaryBody,
    this.summaryAttachmentUrl,
    this.competitionUrl,
    this.competitionTemplate,
    this.category,
  });

  final int id;
  final String title;
  final String description;
  final bool isActive;
  final int? amount;
  final List<String> themes;
  final int? edition;
  final int? maxTeamMembers;
  final int? minTeamMembers;
  final DateTime? registrationStart;
  final DateTime? registrationDeadline;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> scientificCommittee;
  final List<String> executiveCommittee;
  final String? secretariatAddress;
  final String? secretariatPhone;
  final String? logoUrl;
  final String? posterUrl;
  final String? landscapeUrl;
  final String? beneficiaries;
  final List<String> sponsors;
  final String? summaryBody;
  final String? summaryAttachmentUrl;
  final String? competitionUrl;
  final String? competitionTemplate;
  final CompetitionCategory? category;

  String? get imageUrl => landscapeUrl ?? posterUrl ?? logoUrl;

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
