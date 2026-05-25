import '../../../../core/config/app_config.dart';
import '../../domain/entities/news_details.dart';

class NewsDetailsDto {
  const NewsDetailsDto({
    required this.id,
    required this.title,
    required this.body,
    required this.link,
    required this.newsType,
    required this.visitCount,
    this.summary,
    this.metaDescription,
    this.tags,
    this.image,
    this.publishDate,
    this.recordUpdate,
  });

  final int id;
  final String title;
  final String body;
  final String? summary;
  final String? metaDescription;
  final String? tags;
  final String? image;
  final DateTime? publishDate;
  final String link;
  final int newsType;
  final int visitCount;
  final DateTime? recordUpdate;

  factory NewsDetailsDto.fromJson(Map<String, dynamic> json) {
    return NewsDetailsDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      body: _readString(json['body']),
      summary: _readNullableString(json['summary']),
      metaDescription: _readNullableString(json['metaDescription']),
      tags: _readNullableString(json['tags']),
      image: _readNullableString(json['image']),
      publishDate: DateTime.tryParse(_readString(json['publishDate'])),
      link: _readString(json['link']),
      newsType: _readInt(json['newsType']) ?? 0,
      visitCount: _readInt(json['visitCount']) ?? 0,
      recordUpdate: DateTime.tryParse(_readString(json['recordUpdate'])),
    );
  }

  NewsDetails toEntity() {
    return NewsDetails(
      id: id,
      title: title,
      bodyHtml: body,
      summary: summary,
      metaDescription: metaDescription,
      tags: tags,
      imageUrl: image == null ? null : AppConfig.imageUri(image!).toString(),
      publishDate: publishDate,
      linkCode: link,
      newsType: newsType,
      visitCount: visitCount,
      recordUpdate: recordUpdate,
    );
  }
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

String _readString(Object? value, {String fallback = ''}) {
  final text = value is String ? value.trim() : '';
  return text.isEmpty ? fallback : text;
}

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}
