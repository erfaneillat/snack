import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_article.dart';
import 'article_image.dart';

class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final headline = _featuredHeadline(article.title);

    return LayoutBuilder(
      builder: (context, constraints) {
        final headlineWidth = (constraints.maxWidth * 0.68).clamp(190.0, 250.0);

        return SizedBox(
          height: 136,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ArticleImage(
                  imageUrl: article.imageUrl,
                  featured: true,
                  borderRadius: 0,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Color(0xee053174),
                        Color(0xdd06408f),
                        Color(0x8806408f),
                        Color(0x3306408f),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 14,
                  child: SizedBox(
                    width: headlineWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معاون دانشجویی باشگاه پژوهشگران:',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          PersianDigits.format(headline),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                height: 1.32,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(left: 12, bottom: 10, child: _ReadButton()),
                if (article.publishDate != null)
                  Positioned(
                    right: 14,
                    left: 130,
                    bottom: 14,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _FeaturedDate(date: article.publishDate!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _featuredHeadline(String title) {
  const prefix = 'معاون دانشجویی باشگاه پژوهشگران :';
  final trimmed = title.trim();
  if (trimmed.startsWith(prefix)) {
    return trimmed.substring(prefix.length).trim();
  }
  return trimmed;
}

class _ReadButton extends StatelessWidget {
  const _ReadButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.brightTeal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3310bfae),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 17),
          const SizedBox(width: 5),
          Text(
            'مشاهده خبر',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedDate extends StatelessWidget {
  const _FeaturedDate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            PersianDateFormatter.format(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          Icons.calendar_month_outlined,
          color: Colors.white.withValues(alpha: 0.86),
          size: 14,
        ),
      ],
    );
  }
}
