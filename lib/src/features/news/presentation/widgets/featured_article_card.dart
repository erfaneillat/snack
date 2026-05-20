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
        final headlineWidth = (constraints.maxWidth - 128).clamp(210.0, 286.0);

        return SizedBox(
          height: 188,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                        Color(0xf2071b5c),
                        Color(0xe80b2370),
                        Color(0xaa102f8d),
                        Color(0x4406408f),
                      ],
                    ),
                  ),
                ),
                const PositionedDirectional(
                  start: 16,
                  top: 12,
                  child: _FeaturedPill(label: 'خبر ویژه'),
                ),
                PositionedDirectional(
                  top: 48,
                  start: 16,
                  end: constraints.maxWidth - headlineWidth - 16,
                  child: SizedBox(
                    width: headlineWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'معاون دانشجویی باشگاه پژوهشگران:',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          PersianDigits.format(headline),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PositionedDirectional(
                  end: 12,
                  bottom: 12,
                  child: _ReadButton(),
                ),
                if (article.publishDate != null)
                  PositionedDirectional(
                    start: 16,
                    end: 128,
                    bottom: 17,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
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

class _FeaturedPill extends StatelessWidget {
  const _FeaturedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _ReadButton extends StatelessWidget {
  const _ReadButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 13),
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
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'مشاهده خبر',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 18,
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
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          color: Colors.white.withValues(alpha: 0.86),
          size: 15,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            PersianDateFormatter.format(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
        ),
      ],
    );
  }
}
