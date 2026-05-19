import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_feed.dart';
import '../providers/news_providers.dart';
import '../widgets/news_widgets.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(newsFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const _MobileBottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 430
                ? 430.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: feedState.when(
                  skipLoadingOnRefresh: false,
                  data: (feed) => _NewsScrollView(feed: feed),
                  loading: () => const _NewsLoadingView(),
                  error: (error, stackTrace) => _NewsErrorView(
                    onRetry: () => ref.invalidate(newsFeedProvider),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NewsScrollView extends ConsumerWidget {
  const _NewsScrollView({required this.feed});

  final NewsFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleItems = ref.watch(filteredNewsProvider);
    final query = ref.watch(newsSearchQueryProvider);

    return RefreshIndicator(
      color: AppColors.royalBlue,
      onRefresh: () async {
        ref.invalidate(newsFeedProvider);
        await ref.read(newsFeedProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _NewsTopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 0),
              child: NewsToolbar(totalCount: feed.totalCount, enabled: true),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
              child: visibleItems.isEmpty
                  ? EmptyNewsPanel(
                      query: query,
                      onClear: () {
                        ref.read(newsSearchQueryProvider.notifier).clear();
                      },
                    )
                  : _NewsContent(visibleItems: visibleItems),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsLoadingView extends StatelessWidget {
  const _NewsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _NewsTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 11, 12, 0),
            child: NewsToolbar(totalCount: null, enabled: false),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 18),
            child: LoadingNewsList(),
          ),
        ),
      ],
    );
  }
}

class _NewsErrorView extends StatelessWidget {
  const _NewsErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _NewsTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
            child: ErrorNewsPanel(onRetry: onRetry),
          ),
        ),
      ],
    );
  }
}

class _NewsTopBar extends StatelessWidget {
  const _NewsTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اخبار و اطلاعیه‌ها',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.royalBlueDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'جدیدترین خبرهای باشگاه پژوهشگران جوان و نخبگان',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'اعلان‌ها',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.ink,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsContent extends StatefulWidget {
  const _NewsContent({required this.visibleItems});

  final List<NewsArticle> visibleItems;

  @override
  State<_NewsContent> createState() => _NewsContentState();
}

class _NewsContentState extends State<_NewsContent> {
  static const int _initialVisibleCount = 5;
  static const int _pageSize = 5;

  int _visibleCount = _initialVisibleCount;

  @override
  void didUpdateWidget(covariant _NewsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visibleItems != widget.visibleItems) {
      _visibleCount = _initialVisibleCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final featured = widget.visibleItems.first;
    final rest = widget.visibleItems
        .skip(1)
        .take(_visibleCount <= 1 ? 0 : _visibleCount - 1)
        .toList(growable: false);
    final hasMore = _visibleCount < widget.visibleItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeaturedArticleCard(article: featured),
        const SizedBox(height: 8),
        for (var index = 0; index < rest.length; index++) ...[
          NewsArticleCard(article: rest[index]),
          if (index != rest.length - 1) const SizedBox(height: 8),
        ],
        if (hasMore) ...[
          const SizedBox(height: 8),
          _LoadMoreButton(
            onPressed: () {
              setState(() {
                _visibleCount += _pageSize;
                if (_visibleCount > widget.visibleItems.length) {
                  _visibleCount = widget.visibleItems.length;
                }
              });
            },
          ),
        ],
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        label: const Text('بارگذاری بیشتر'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brightTeal,
          textStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.softBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.home_outlined,
                      label: 'خانه',
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.article_rounded,
                      label: 'اخبار',
                      selected: true,
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'رویدادها',
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'پروفایل',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.royalBlue : AppColors.muted;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}
