import 'package:html/parser.dart' as html_parser;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/competition_item.dart';

class CompetitionItemDto {
  const CompetitionItemDto({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    this.amount,
    this.registrationStart,
    this.registrationDeadline,
    this.startDate,
    this.endDate,
    this.logoPath,
    this.posterPath,
    this.competitionUrl,
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
  final String? logoPath;
  final String? posterPath;
  final String? competitionUrl;

  factory CompetitionItemDto.fromJson(Map<String, dynamic> json) {
    return CompetitionItemDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      description: _readDescription(json['description']),
      isActive: _readBool(json['isActive']),
      amount: _readInt(json['amount']),
      registrationStart: _readDate(json['registrationStart']),
      registrationDeadline: _readDate(json['registrationDeadline']),
      startDate: _readDate(json['startDate']),
      endDate: _readDate(json['endDate']),
      logoPath: _readNullableString(json['logoPath']),
      posterPath: _readNullableString(json['posterPath']),
      competitionUrl: _readNullableString(json['competitionUrl']),
    );
  }

  CompetitionItem toEntity() {
    final descriptor = '$title $description';
    return CompetitionItem(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      amount: amount,
      registrationStart: registrationStart,
      registrationDeadline: registrationDeadline,
      startDate: startDate,
      endDate: endDate,
      logoUrl: _imageUrl(logoPath),
      posterUrl: _imageUrl(posterPath),
      competitionUrl: competitionUrl,
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
  return parsed
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
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
  final text = _normalize(value);
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

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
}
