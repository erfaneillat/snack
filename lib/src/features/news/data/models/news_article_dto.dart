import '../../../../core/config/app_config.dart';
import '../../domain/entities/news_article.dart';

class NewsArticleDto {
  const NewsArticleDto({
    required this.id,
    required this.title,
    required this.publishDate,
    required this.link,
    required this.newsType,
    this.summary,
    this.image,
  });

  final int id;
  final String title;
  final String? summary;
  final String? image;
  final DateTime? publishDate;
  final String link;
  final int newsType;

  factory NewsArticleDto.fromJson(Map<String, dynamic> json) {
    return NewsArticleDto(
      id: _readInt(json['id']) ?? 0,
      title: _readString(json['title'], fallback: 'بدون عنوان'),
      summary: _readNullableString(json['summary']),
      image: _readNullableString(json['image']),
      publishDate: DateTime.tryParse(_readString(json['publishDate'])),
      link: _readString(json['link']),
      newsType: _readInt(json['newsType']) ?? 0,
    );
  }

  NewsArticle toEntity() {
    return NewsArticle(
      id: id,
      title: title,
      summary: summary,
      imageUrl: image == null ? null : AppConfig.imageUri(image!).toString(),
      publishDate: publishDate,
      linkCode: link,
      newsType: newsType,
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
