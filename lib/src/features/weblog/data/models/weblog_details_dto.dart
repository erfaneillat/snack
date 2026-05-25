import '../../../../core/config/app_config.dart';
import '../../domain/entities/weblog_details.dart';

class WeblogDetailsDto {
  const WeblogDetailsDto({
    required this.id,
    required this.title,
    required this.body,
    required this.link,
    this.metaDescription,
    this.keywords,
    this.author,
    this.picture,
    this.tags,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String? metaDescription;
  final String? keywords;
  final String? author;
  final String? picture;
  final String? tags;
  final String link;
  final DateTime? createdAt;

  factory WeblogDetailsDto.fromJson(Map<String, dynamic> json) {
    return WeblogDetailsDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      body: _readString(json['body']),
      metaDescription: _readNullableString(json['metaDescription']),
      keywords: _readNullableString(json['keywords']),
      author: _readNullableString(json['author']),
      picture: _readNullableString(json['picture'] ?? json['image']),
      tags: _readNullableString(json['tags']),
      link: _readString(json['link']),
      createdAt: DateTime.tryParse(_readString(json['createdAt'])),
    );
  }

  WeblogDetails toEntity() {
    return WeblogDetails(
      id: id,
      title: title,
      bodyHtml: body,
      metaDescription: metaDescription,
      keywords: keywords,
      author: author,
      imageUrl: picture == null
          ? null
          : AppConfig.imageUri(picture!).toString(),
      tags: tags,
      linkCode: link,
      createdAt: createdAt,
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
