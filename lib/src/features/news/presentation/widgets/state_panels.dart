import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class LoadingNewsList extends StatelessWidget {
  const LoadingNewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Skeleton(height: 188),
        const SizedBox(height: 10),
        for (var i = 0; i < 5; i++) ...[
          const _Skeleton(height: 124),
          if (i != 4) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class EmptyNewsPanel extends StatelessWidget {
  const EmptyNewsPanel({super.key, required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppStatePanel(
      icon: Icons.search_off_rounded,
      title: 'خبری پیدا نشد',
      body: 'برای عبارت «$query» نتیجه ای در این صفحه وجود ندارد.',
      actionLabel: 'حذف جستجو',
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
        borderRadius: BorderRadius.circular(10),
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

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.teal.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
