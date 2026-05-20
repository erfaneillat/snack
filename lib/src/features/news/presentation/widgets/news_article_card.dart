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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          constraints: const BoxConstraints(minHeight: 124),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0f000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: ArticleImage(
                  imageUrl: article.imageUrl,
                  borderRadius: 9,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _NewsArticleText(article: article)),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.brightTeal,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsArticleText extends StatelessWidget {
  const _NewsArticleText({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final summary = article.summary?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                PersianDigits.format(article.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _NewsBadge(),
          ],
        ),
        if (summary != null && summary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            PersianDigits.format(summary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (article.publishDate != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.teal,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  PersianDateFormatter.format(article.publishDate!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
            ],
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
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          'خبر رسمی',
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.teal,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}
