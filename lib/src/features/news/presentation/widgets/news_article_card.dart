import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/forward_chevron.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_article.dart';
import '../pages/news_details_page.dart';
import 'article_image.dart';
import 'news_toolbar.dart';

class NewsArticleCard extends StatelessWidget {
  const NewsArticleCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    const radius = 8.0;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => NewsDetailsPage.open(context, article),
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.softBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0f000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: ArticleImage(
                  imageUrl: article.imageUrl,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _NewsArticleText(article: article)),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const ForwardChevron(color: AppColors.teal),
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
    final publishDate = article.publishDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            _NewsBadge(label: newsTypeLabel(article.newsType)),
            const Spacer(),
            if (publishDate != null)
              Flexible(child: _NewsArticleDate(date: publishDate)),
          ],
        ),
        const SizedBox(height: 7),
        Text(
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
      ],
    );
  }
}

class _NewsBadge extends StatelessWidget {
  const _NewsBadge({required this.label});

  final String label;

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
          label,
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

class _NewsArticleDate extends StatelessWidget {
  const _NewsArticleDate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            PersianDateFormatter.format(date),
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
    );
  }
}
