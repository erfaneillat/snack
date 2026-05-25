import '../../../../core/config/app_config.dart';
import '../../domain/entities/weblog_post.dart';

class WeblogPostDto {
  const WeblogPostDto({
    required this.id,
    required this.title,
    required this.link,
    this.summary,
    this.picture,
    this.author,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? summary;
  final String? picture;
  final String? author;
  final DateTime? createdAt;
  final String link;

  factory WeblogPostDto.fromJson(Map<String, dynamic> json) {
    return WeblogPostDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      summary: _readNullableString(json['summary']),
      picture: _readNullableString(json['picture'] ?? json['image']),
      author: _readNullableString(json['author']),
      createdAt: DateTime.tryParse(_readString(json['createdAt'])),
      link: _readString(json['link']),
    );
  }

  WeblogPost toEntity() {
    return WeblogPost(
      id: id,
      title: title,
      summary: summary,
      imageUrl: picture == null
          ? null
          : AppConfig.imageUri(picture!).toString(),
      author: author,
      createdAt: createdAt,
      linkCode: link,
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
