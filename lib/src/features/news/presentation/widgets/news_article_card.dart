import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_article.dart';
import 'article_image.dart';

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(7),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 64,
            child: ArticleImage(imageUrl: article.imageUrl, borderRadius: 6),
          ),
          const SizedBox(width: 9),
          Expanded(child: _NewsArticleText(article: article)),
          const SizedBox(width: 7),
          const Align(alignment: Alignment.bottomCenter, child: _NewsBadge()),
        ],
      ),
    );
  }
}

class _NewsArticleText extends StatelessWidget {
  const _NewsArticleText({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              PersianDigits.format(article.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                height: 1.55,
              ),
            ),
          ),
        ),
        if (article.publishDate != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PersianDateFormatter.format(article.publishDate!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.muted,
                  size: 12,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NewsBadge extends StatelessWidget {
  const _NewsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff4f8ff),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffdfeaff)),
      ),
      child: Center(
        child: Text(
          'خبر رسمی',
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.royalBlue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}
