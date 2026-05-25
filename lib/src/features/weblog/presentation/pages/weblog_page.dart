import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/forward_chevron.dart';
import '../../../../app/widgets/mobile_page_header.dart';
import '../../../../app/widgets/shimmer.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../../news/presentation/widgets/article_image.dart';
import '../../domain/entities/weblog_feed.dart';
import '../../domain/entities/weblog_post.dart';
import '../providers/weblog_providers.dart';
import 'weblog_details_page.dart';

class WeblogPage extends ConsumerWidget {
  const WeblogPage({super.key});

  static const routeName = '/weblog';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(weblogFeedProvider);

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
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  data: (feed) => _WeblogScrollView(feed: feed),
                  loading: () => const _WeblogLoadingView(),
                  error: (error, stackTrace) => _WeblogErrorView(
                    onRetry: () => ref.invalidate(weblogFeedProvider),
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

class _WeblogScrollView extends ConsumerStatefulWidget {
  const _WeblogScrollView({required this.feed});

  final WeblogFeed feed;

  @override
  ConsumerState<_WeblogScrollView> createState() => _WeblogScrollViewState();
}

class _WeblogScrollViewState extends ConsumerState<_WeblogScrollView> {
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
  void didUpdateWidget(covariant _WeblogScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queueLoadMoreIfNeeded();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      ref.read(weblogFeedProvider.notifier).loadNextPage();
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
    final visiblePosts = ref.watch(filteredWeblogPostsProvider);
    final query = ref.watch(weblogSearchQueryProvider);
    final hasSearchQuery = query.trim().isNotEmpty;

    return RefreshIndicator(
      color: AppColors.royalBlue,
      onRefresh: () async {
        ref.invalidate(weblogFeedProvider);
        await ref.read(weblogFeedProvider.future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _WeblogTopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: const _WeblogToolbar(enabled: true),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: visiblePosts.isEmpty
                  ? _EmptyWeblogPanel(
                      query: query,
                      onAction: () {
                        if (hasSearchQuery) {
                          ref.read(weblogSearchQueryProvider.notifier).clear();
                          return;
                        }
                        ref.invalidate(weblogFeedProvider);
                      },
                    )
                  : _WeblogContent(posts: visiblePosts),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeblogLoadingView extends StatelessWidget {
  const _WeblogLoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _WeblogTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _WeblogToolbar(enabled: false),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 32),
            child: _LoadingWeblogList(),
          ),
        ),
      ],
    );
  }
}

class _WeblogErrorView extends StatelessWidget {
  const _WeblogErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _WeblogTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            child: _WeblogStatePanel(
              icon: Icons.wifi_off_rounded,
              title: 'دریافت وبلاگ ناموفق بود',
              body: 'ارتباط با سرویس وبلاگ برقرار نشد. دوباره تلاش کنید.',
              actionLabel: 'تلاش دوباره',
              onAction: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeblogTopBar extends StatelessWidget {
  const _WeblogTopBar();

  @override
  Widget build(BuildContext context) {
    return const MobilePageHeader(
      title: 'وبلاگ',
      subtitle: 'یادداشت‌ها و گزارش‌های باشگاه پژوهشگران جوان و نخبگان',
    );
  }
}

class _WeblogToolbar extends ConsumerStatefulWidget {
  const _WeblogToolbar({required this.enabled});

  final bool enabled;

  @override
  ConsumerState<_WeblogToolbar> createState() => _WeblogToolbarState();
}

class _WeblogToolbarState extends ConsumerState<_WeblogToolbar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(weblogSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(weblogSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(weblogSearchQueryProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    final query = ref.watch(weblogSearchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            key: const ValueKey('weblog-search-field'),
            controller: _controller,
            enabled: widget.enabled,
            textInputAction: TextInputAction.search,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            textAlignVertical: TextAlignVertical.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              ref.read(weblogSearchQueryProvider.notifier).setQuery(value);
            },
            onSubmitted: (value) {
              ref.read(weblogSearchQueryProvider.notifier).submit(value);
            },
            decoration: InputDecoration(
              hintText: 'جستجو در عنوان یا خلاصه...',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'پاک کردن',
                      onPressed: _clear,
                      icon: const Icon(Icons.close_rounded, size: 19),
                    ),
              prefixIconColor: AppColors.muted,
              suffixIconColor: AppColors.muted,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.softBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.softBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.softBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeblogContent extends StatelessWidget {
  const _WeblogContent({required this.posts});

  final List<WeblogPost> posts;

  @override
  Widget build(BuildContext context) {
    final featured = posts.first;
    final rest = posts.skip(1).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FeaturedWeblogCard(post: featured),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 16),
          const _WeblogSectionHeader(),
          const SizedBox(height: 10),
          for (var index = 0; index < rest.length; index++) ...[
            _WeblogPostCard(post: rest[index]),
            if (index != rest.length - 1) const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _WeblogSectionHeader extends StatelessWidget {
  const _WeblogSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 8,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'آخرین مطالب',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedWeblogCard extends StatelessWidget {
  const _FeaturedWeblogCard({required this.post});

  final WeblogPost post;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => WeblogDetailsPage.open(context, post),
        child: Ink(
          height: 228,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1f071b5c),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArticleImage(
                imageUrl: post.imageUrl,
                featured: true,
                borderRadius: 0,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xf2102f45),
                      Color(0xe80c4a6e),
                      Color(0xb70f766e),
                      Color(0x550f766e),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.36),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        const _FeaturedPill(label: 'تازه‌ترین مطلب'),
                        const Spacer(),
                        if (post.createdAt != null)
                          Flexible(child: _FeaturedDate(date: post.createdAt!)),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              PersianDigits.format(post.title),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    height: 1.35,
                                  ),
                            ),
                            if (_hasMeaningfulText(post.summary)) ...[
                              const SizedBox(height: 8),
                              Text(
                                PersianDigits.format(post.summary!.trim()),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.84,
                                      ),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.55,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: const [_ReadPreviewButton(), Spacer()],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        color: AppColors.brightTeal,
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

class _ReadPreviewButton extends StatelessWidget {
  const _ReadPreviewButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(19),
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
            'مشاهده مطلب',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(width: 6),
          const ForwardChevron(color: Colors.white, size: 18),
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

class _WeblogPostCard extends StatelessWidget {
  const _WeblogPostCard({required this.post});

  final WeblogPost post;

  @override
  Widget build(BuildContext context) {
    const radius = 8.0;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => WeblogDetailsPage.open(context, post),
        child: Container(
          constraints: const BoxConstraints(minHeight: 126),
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
                width: 88,
                height: 88,
                child: ArticleImage(imageUrl: post.imageUrl, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              Expanded(child: _WeblogPostText(post: post)),
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

class _WeblogPostText extends StatelessWidget {
  const _WeblogPostText({required this.post});

  final WeblogPost post;

  @override
  Widget build(BuildContext context) {
    final summary = post.summary?.trim();
    final createdAt = post.createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (createdAt != null) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _WeblogDate(date: createdAt),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          PersianDigits.format(post.title),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _WeblogDate extends StatelessWidget {
  const _WeblogDate({required this.date});

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

class _EmptyWeblogPanel extends StatelessWidget {
  const _EmptyWeblogPanel({required this.query, required this.onAction});

  final String query;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();

    return _WeblogStatePanel(
      icon: Icons.search_off_rounded,
      title: 'مطلبی پیدا نشد',
      body: trimmedQuery.isEmpty
          ? 'در حال حاضر مطلبی برای نمایش وجود ندارد.'
          : 'برای عبارت «${PersianDigits.format(trimmedQuery)}» نتیجه‌ای در وبلاگ وجود ندارد.',
      actionLabel: trimmedQuery.isEmpty ? 'تلاش دوباره' : 'نمایش همه مطالب',
      onAction: onAction,
    );
  }
}

class _WeblogStatePanel extends StatelessWidget {
  const _WeblogStatePanel({
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
            textDirection: TextDirection.rtl,
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

class _LoadingWeblogList extends StatelessWidget {
  const _LoadingWeblogList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FeaturedWeblogSkeleton(),
        const SizedBox(height: 16),
        const _WeblogSectionHeaderSkeleton(),
        const SizedBox(height: 10),
        for (var i = 0; i < 5; i++) ...[
          const _WeblogPostSkeleton(),
          if (i != 4) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FeaturedWeblogSkeleton extends StatelessWidget {
  const _FeaturedWeblogSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 228,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              ShimmerBlock(width: 88, height: 26, radius: 13),
              Spacer(),
              ShimmerBlock(width: 92, height: 14, radius: 7),
            ],
          ),
          Spacer(),
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
          SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.62,
              child: ShimmerBlock(height: 12, radius: 6),
            ),
          ),
          SizedBox(height: 16),
          Row(
            textDirection: TextDirection.rtl,
            children: [ShimmerBlock(width: 108, height: 38, radius: 19)],
          ),
        ],
      ),
    );
  }
}

class _WeblogSectionHeaderSkeleton extends StatelessWidget {
  const _WeblogSectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      textDirection: TextDirection.rtl,
      children: [
        ShimmerBlock(width: 8, height: 26, radius: 4),
        SizedBox(width: 9),
        ShimmerBlock(width: 88, height: 16, radius: 8),
      ],
    );
  }
}

class _WeblogPostSkeleton extends StatelessWidget {
  const _WeblogPostSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 126,
      child: Row(
        textDirection: TextDirection.rtl,
        children: const [
          ShimmerBlock(width: 88, height: 88, radius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBlock(width: 72, height: 12, radius: 6),
                ),
                SizedBox(height: 10),
                ShimmerBlock(height: 15, radius: 7),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.76,
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

bool _hasMeaningfulText(String? value) {
  return value != null && value.trim().isNotEmpty;
}
