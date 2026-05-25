import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/shimmer.dart';

class LoadingNewsList extends StatelessWidget {
  const LoadingNewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FeaturedNewsSkeleton(),
        const SizedBox(height: 12),
        for (var i = 0; i < 5; i++) ...[
          const _NewsListSkeleton(),
          if (i != 4) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class EmptyNewsPanel extends StatelessWidget {
  const EmptyNewsPanel({
    super.key,
    required this.query,
    required this.onClear,
    this.filterLabel,
  });

  final String query;
  final VoidCallback onClear;
  final String? filterLabel;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    final currentFilter = filterLabel;
    final body = trimmedQuery.isNotEmpty
        ? 'برای عبارت «$trimmedQuery» نتیجه ای در خبرهای فعلی وجود ندارد.'
        : currentFilter == null
        ? 'در حال حاضر خبری برای نمایش وجود ندارد.'
        : 'در بخش «$currentFilter» خبری برای نمایش وجود ندارد.';

    return AppStatePanel(
      icon: Icons.search_off_rounded,
      title: 'خبری پیدا نشد',
      body: body,
      actionLabel: trimmedQuery.isEmpty && currentFilter == null
          ? 'تلاش دوباره'
          : 'نمایش همه خبرها',
      onAction: onClear,
    );
  }
}

class ErrorNewsPanel extends StatelessWidget {
  const ErrorNewsPanel({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppStatePanel(
      icon: Icons.wifi_off_rounded,
      title: 'دریافت خبرها ناموفق بود',
      body: 'ارتباط با سرویس خبری برقرار نشد. دوباره تلاش کنید.',
      actionLabel: 'تلاش دوباره',
      onAction: onRetry,
    );
  }
}

class AppStatePanel extends StatelessWidget {
  const AppStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.teal),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FeaturedNewsSkeleton extends StatelessWidget {
  const _FeaturedNewsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 196,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShimmerBlock(width: 72, height: 26, radius: 13),
              Spacer(),
              ShimmerBlock(width: 92, height: 14, radius: 7),
            ],
          ),
          Spacer(),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.66,
              child: ShimmerBlock(height: 15, radius: 7),
            ),
          ),
          SizedBox(height: 9),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: ShimmerBlock(height: 18, radius: 8),
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.74,
              child: ShimmerBlock(height: 18, radius: 8),
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShimmerBlock(width: 108, height: 38, radius: 19),
          ),
        ],
      ),
    );
  }
}

class _NewsListSkeleton extends StatelessWidget {
  const _NewsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 118,
      child: Row(
        textDirection: TextDirection.rtl,
        children: const [
          ShimmerBlock(width: 82, height: 82, radius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ShimmerBlock(width: 58, height: 22, radius: 11),
                    Spacer(),
                    ShimmerBlock(width: 72, height: 12, radius: 6),
                  ],
                ),
                SizedBox(height: 10),
                ShimmerBlock(height: 15, radius: 7),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.72,
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBlock(height: 15, radius: 7),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBlock(width: 28, height: 28, radius: 14),
        ],
      ),
    );
  }
}
