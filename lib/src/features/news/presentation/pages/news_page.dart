import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/mobile_page_header.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_feed.dart';
import '../providers/news_providers.dart';
import '../widgets/news_widgets.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  static const routeName = '/news';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(newsFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(0.0, 430.0).toDouble();

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

class _NewsScrollView extends ConsumerStatefulWidget {
  const _NewsScrollView({required this.feed});

  final NewsFeed feed;

  @override
  ConsumerState<_NewsScrollView> createState() => _NewsScrollViewState();
}

class _NewsScrollViewState extends ConsumerState<_NewsScrollView> {
  static const double _loadMoreThreshold = 360;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NewsScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queueLoadMoreIfNeeded();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      ref.read(newsFeedProvider.notifier).loadNextPage();
    }
  }

  void _queueLoadMoreIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _handleScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    _queueLoadMoreIfNeeded();
    final visibleItems = ref.watch(filteredNewsProvider);
    final query = ref.watch(newsSearchQueryProvider);

    return RefreshIndicator(
      color: AppColors.royalBlue,
      onRefresh: () async {
        ref.invalidate(newsFeedProvider);
        await ref.read(newsFeedProvider.future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _NewsTopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: NewsToolbar(
                totalCount: widget.feed.totalCount,
                enabled: true,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
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
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: NewsToolbar(totalCount: null, enabled: false),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 32),
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
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
    return const MobilePageHeader(
      title: 'اخبار و اطلاعیه‌ها',
      subtitle: 'جدیدترین خبرهای باشگاه پژوهشگران جوان و نخبگان',
    );
  }
}

class _NewsContent extends StatelessWidget {
  const _NewsContent({required this.visibleItems});

  final List<NewsArticle> visibleItems;

  @override
  Widget build(BuildContext context) {
    final featured = visibleItems.first;
    final rest = visibleItems.skip(1).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeaturedArticleCard(article: featured),
        const SizedBox(height: 10),
        for (var index = 0; index < rest.length; index++) ...[
          NewsArticleCard(article: rest[index]),
          if (index != rest.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
