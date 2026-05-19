import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_feed.dart';
import 'news_metric_tile.dart';

class NewsSidebar extends StatelessWidget {
  const NewsSidebar({
    super.key,
    required this.feed,
    required this.visibleItems,
  });

  final NewsFeed feed;
  final List<NewsArticle> visibleItems;

  @override
  Widget build(BuildContext context) {
    final latest = feed.items
        .map((article) => article.publishDate)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (previous, date) {
          if (previous == null || date.isAfter(previous)) {
            return date;
          }
          return previous;
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نمای کلی',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              NewsMetricTile(
                icon: Icons.article_outlined,
                value: PersianDigits.format(feed.totalCount),
                label: 'کل خبرها',
              ),
              const SizedBox(height: 10),
              NewsMetricTile(
                icon: Icons.filter_alt_outlined,
                value: PersianDigits.format(visibleItems.length),
                label: 'نمایش در صفحه',
              ),
              const SizedBox(height: 10),
              NewsMetricTile(
                icon: Icons.update_rounded,
                value: latest == null
                    ? '...'
                    : PersianDateFormatter.format(latest),
                label: 'تازه ترین تاریخ',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.header,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                'منبع رسمی',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اطلاعات از سرویس خبری باشگاه پژوهشگران جوان و نخبگان دانشگاه آزاد اسلامی خوانده می شود.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xffc9dce5),
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
