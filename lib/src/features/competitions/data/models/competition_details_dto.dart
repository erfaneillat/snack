import 'package:html/parser.dart' as html_parser;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/competition_details.dart';
import '../../domain/entities/competition_item.dart';

class CompetitionDetailsDto {
  const CompetitionDetailsDto({
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
    this.logoPath,
    this.posterPath,
    this.landscapePath,
    this.beneficiaries,
    this.sponsors = const [],
    this.summaryBody,
    this.summaryAttachment,
    this.competitionUrl,
    this.competitionTemplate,
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
  final String? logoPath;
  final String? posterPath;
  final String? landscapePath;
  final String? beneficiaries;
  final List<String> sponsors;
  final String? summaryBody;
  final String? summaryAttachment;
  final String? competitionUrl;
  final String? competitionTemplate;

  factory CompetitionDetailsDto.fromJson(Map<String, dynamic> json) {
    return CompetitionDetailsDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      description: _readDescription(json['description']),
      isActive: _readBool(json['isActive']),
      amount: _readInt(json['amount']),
      themes: _readDelimitedList(json['themes']),
      edition: _readInt(json['edition']),
      maxTeamMembers: _readInt(json['maxTeamMembers']),
      minTeamMembers: _readInt(json['minTeamMembers']),
      registrationStart: _readDate(json['registrationStart']),
      registrationDeadline: _readDate(json['registrationDeadline']),
      startDate: _readDate(json['startDate']),
      endDate: _readDate(json['endDate']),
      scientificCommittee: _readLineList(json['scientificCommittee']),
      executiveCommittee: _readLineList(json['executiveCommittee']),
      secretariatAddress: _readNullableString(json['secretariatAddress']),
      secretariatPhone: _readNullableString(json['secretariatPhone']),
      logoPath: _readNullableString(json['logoPath']),
      posterPath: _readNullableString(json['posterPath']),
      landscapePath: _readNullableString(json['landscapePath']),
      beneficiaries: _readNullableString(json['beneficiaries']),
      sponsors: _readDelimitedList(json['sponsors']),
      summaryBody: _readDescriptionOrNull(json['summaryBody']),
      summaryAttachment: _readNullableString(json['summaryAttachment']),
      competitionUrl: _readNullableString(
        json['competitionURL'] ?? json['competitionUrl'],
      ),
      competitionTemplate: _readNullableString(json['competitionTemplate']),
    );
  }

  CompetitionDetails toEntity() {
    final descriptor = '$title $description ${themes.join(' ')}';
    return CompetitionDetails(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      amount: amount,
      themes: themes,
      edition: edition,
      maxTeamMembers: maxTeamMembers,
      minTeamMembers: minTeamMembers,
      registrationStart: registrationStart,
      registrationDeadline: registrationDeadline,
      startDate: startDate,
      endDate: endDate,
      scientificCommittee: scientificCommittee,
      executiveCommittee: executiveCommittee,
      secretariatAddress: secretariatAddress,
      secretariatPhone: secretariatPhone,
      logoUrl: _imageUrl(logoPath),
      posterUrl: _imageUrl(posterPath),
      landscapeUrl: _imageUrl(landscapePath),
      beneficiaries: beneficiaries,
      sponsors: sponsors,
      summaryBody: summaryBody,
      summaryAttachmentUrl: _imageUrl(summaryAttachment),
      competitionUrl: competitionUrl,
      competitionTemplate: competitionTemplate,
      category: _readCategory(descriptor),
    );
  }
}

String _readString(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

String _readDescription(Object? value) {
  final html = _readString(value);
  if (html.isEmpty) {
    return '';
  }

  final parsed = html_parser.parseFragment(html).text ?? '';
  return _normalizeText(parsed);
}

String? _readDescriptionOrNull(Object? value) {
  final text = _readDescription(value);
  return text.isEmpty ? null : text;
}

List<String> _readDelimitedList(Object? value) {
  return _readString(value)
      .split(RegExp(r'[,،]'))
      .map(_normalizeText)
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> _readLineList(Object? value) {
  return _readString(value)
      .split(RegExp(r'[\r\n]+'))
      .map(_normalizeText)
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
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

String? _imageUrl(String? fileName) {
  final value = fileName?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  return AppConfig.imageUri(value).toString();
}

CompetitionCategory? _readCategory(String value) {
  final text = _normalizeForSearch(value);
  if (text.contains('پرستار') ||
      text.contains('مامایی') ||
      text.contains('آناتومی') ||
      text.contains('پزشک')) {
    return CompetitionCategory.medical;
  }
  if (text.contains('زبان') ||
      text.contains('انگلیسی') ||
      text.contains('ترجمه') ||
      text.contains('reading')) {
    return CompetitionCategory.language;
  }
  if (text.contains('برنامه نویسی') ||
      text.contains('کامپیوتر') ||
      text.contains('python') ||
      text.contains('اسکرچ') ||
      text.contains('هوش مصنوعی')) {
    return CompetitionCategory.technology;
  }
  if (text.contains('نقاشی') ||
      text.contains('هنری') ||
      text.contains('محتوا')) {
    return CompetitionCategory.art;
  }
  if (text.contains('حسابدار') ||
      text.contains('مدیریت') ||
      text.contains('استارتاپ') ||
      text.contains('کسب')) {
    return CompetitionCategory.business;
  }
  if (text.contains('علمی') ||
      text.contains('میکروبیولوژی') ||
      text.contains('میکروسکوپی') ||
      text.contains('پژوهش')) {
    return CompetitionCategory.science;
  }
  if (text.contains('شخصیت') ||
      text.contains('حقوق') ||
      text.contains('ادبیات')) {
    return CompetitionCategory.humanities;
  }
  return null;
}

String _normalizeText(String value) {
  return value
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'[ \t\r\n]+'), ' ')
      .trim();
}

String _normalizeForSearch(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
