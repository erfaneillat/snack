import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_feed.dart';
import 'news_metric_tile.dart';
import 'responsive_page_frame.dart';

class NewsHeroHeader extends StatelessWidget {
  const NewsHeroHeader({super.key, required this.feed});

  final NewsFeed? feed;

  @override
  Widget build(BuildContext context) {
    final latestDate = feed?.items
        .map((article) => article.publishDate)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, date) {
          if (latest == null || date.isAfter(latest)) {
            return date;
          }
          return latest;
        });

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.header),
      child: ResponsivePageFrame(
        top: 22,
        bottom: 34,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroNav(onOpenSite: _openSite),
            const SizedBox(height: 34),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 820;
                final titleBlock = _HeroTitle(compact: compact);
                final metrics = _HeroMetrics(
                  feed: feed,
                  latestDate: latestDate,
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titleBlock, const SizedBox(height: 24), metrics],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 28),
                    Flexible(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: metrics,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSite() async {
    await launchUrl(AppConfig.siteUri(), mode: LaunchMode.externalApplication);
  }
}

class _HeroNav extends StatelessWidget {
  const _HeroNav({required this.onOpenSite});

  final VoidCallback onOpenSite;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const _BrandMark(),
        const _NavChip(label: 'اخبار', selected: true),
        const _NavChip(label: 'پژوهش'),
        const _NavChip(label: 'رویدادها'),
        OutlinedButton.icon(
          onPressed: onOpenSite,
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('سایت باشگاه'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: AppColors.header),
        ),
        const SizedBox(width: 10),
        Text(
          'پرتال دانشگاه',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0 : 0.16),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? AppColors.header : const Color(0xffd4e6ee),
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اخبار دانشگاه آزاد اسلامی',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontSize: compact ? 28 : 34,
            height: 1.45,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'آخرین اطلاعیه ها، رویدادها و خبرهای باشگاه پژوهشگران جوان و نخبگان',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xffc9dce5),
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroMetrics extends StatelessWidget {
  const _HeroMetrics({required this.feed, required this.latestDate});

  final NewsFeed? feed;
  final DateTime? latestDate;

  @override
  Widget build(BuildContext context) {
    final currentFeed = feed;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        NewsMetricTile(
          dark: true,
          icon: Icons.article_outlined,
          value: currentFeed == null
              ? '...'
              : PersianDigits.format(currentFeed.totalCount),
          label: 'خبر منتشر شده',
        ),
        NewsMetricTile(
          dark: true,
          icon: Icons.calendar_month_rounded,
          value: latestDate == null
              ? '...'
              : PersianDateFormatter.format(latestDate!),
          label: 'آخرین انتشار',
        ),
        NewsMetricTile(
          dark: true,
          icon: currentFeed?.isFallback == true
              ? Icons.inventory_2_outlined
              : Icons.cloud_done_outlined,
          value: currentFeed?.isFallback == true ? 'نمونه' : 'زنده',
          label: 'منبع داده',
        ),
      ],
    );
  }
}
