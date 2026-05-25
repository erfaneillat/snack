import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/forward_chevron.dart';
import '../../../../app/widgets/mobile_page_header.dart';
import '../../../../app/widgets/shimmer.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/competition_feed.dart';
import '../../domain/entities/competition_item.dart';
import 'competition_details_page.dart';
import '../providers/competitions_providers.dart';
import '../../../news/presentation/widgets/article_image.dart';
import '../../../news/presentation/widgets/state_panels.dart';

class CompetitionsPage extends ConsumerWidget {
  const CompetitionsPage({super.key});

  static const routeName = '/competitions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(competitionsFeedProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                    data: (feed) => _CompetitionsScrollView(feed: feed),
                    loading: () => const _CompetitionsLoadingView(),
                    error: (error, stackTrace) => _CompetitionsErrorView(
                      onRetry: () => ref.invalidate(competitionsFeedProvider),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompetitionsScrollView extends ConsumerStatefulWidget {
  const _CompetitionsScrollView({required this.feed});

  final CompetitionFeed feed;

  @override
  ConsumerState<_CompetitionsScrollView> createState() =>
      _CompetitionsScrollViewState();
}

class _CompetitionsScrollViewState
    extends ConsumerState<_CompetitionsScrollView> {
  static const double _loadMoreThreshold = 360;

  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchController = TextEditingController(
      text: ref.read(competitionSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CompetitionsScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queueLoadMoreIfNeeded();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      ref.read(competitionsFeedProvider.notifier).loadNextPage();
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

  Future<void> _refresh() async {
    ref.invalidate(competitionsFeedProvider);
    await ref.read(competitionsFeedProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    _queueLoadMoreIfNeeded();

    ref.listen<String>(competitionSearchQueryProvider, (previous, next) {
      if (next != _searchController.text) {
        _searchController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    final visibleItems = ref.watch(filteredCompetitionsProvider);
    final query = ref.watch(competitionSearchQueryProvider);
    final selectedFilter = ref.watch(selectedCompetitionFilterProvider);
    final hasLocalFilter =
        query.trim().isNotEmpty || selectedFilter != CompetitionQuickFilter.all;

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _CompetitionsTopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _CompetitionsToolbar(
                controller: _searchController,
                feed: widget.feed,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: visibleItems.isEmpty
                  ? _EmptyCompetitionsPanel(
                      query: query,
                      filter: selectedFilter,
                      onClear: () {
                        ref
                            .read(competitionSearchQueryProvider.notifier)
                            .clear();
                        ref
                            .read(selectedCompetitionFilterProvider.notifier)
                            .clear();
                        if (!hasLocalFilter) {
                          ref.invalidate(competitionsFeedProvider);
                        }
                      },
                    )
                  : _CompetitionsContent(items: visibleItems),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionsTopBar extends StatelessWidget {
  const _CompetitionsTopBar();

  @override
  Widget build(BuildContext context) {
    return const MobilePageHeader(
      title: 'مسابقات فعال',
      subtitle: 'ثبت‌نام، زمان‌بندی و جزئیات مسابقات باشگاه پژوهشگران',
    );
  }
}

class _CompetitionsToolbar extends ConsumerWidget {
  const _CompetitionsToolbar({required this.controller, required this.feed});

  final TextEditingController controller;
  final CompetitionFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(competitionSearchQueryProvider);
    final selectedFilter = ref.watch(selectedCompetitionFilterProvider);
    final filterItems = _buildFilterItems(feed.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            key: const ValueKey('competitions-search-field'),
            controller: controller,
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
              ref.read(competitionSearchQueryProvider.notifier).setQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'جستجو در عنوان، توضیحات یا وضعیت...',
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
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(competitionSearchQueryProvider.notifier)
                            .clear();
                      },
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          textDirection: TextDirection.rtl,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in filterItems)
              _CompetitionFilterChip(
                key: ValueKey('competition-filter-${item.filter.name}'),
                data: item,
                selected: selectedFilter == item.filter,
                onTap: () {
                  ref
                      .read(selectedCompetitionFilterProvider.notifier)
                      .select(item.filter);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _CompetitionFilterChip extends StatelessWidget {
  const _CompetitionFilterChip({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _CompetitionFilterData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.royalBlueDark;
    final background = selected ? AppColors.teal : AppColors.surface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.teal : AppColors.softBorder,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x220f766e),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Icon(data.icon, color: foreground, size: 17),
              const SizedBox(width: 6),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionFilterData {
  const _CompetitionFilterData({
    required this.filter,
    required this.label,
    required this.icon,
  });

  final CompetitionQuickFilter filter;
  final String label;
  final IconData icon;
}

List<_CompetitionFilterData> _buildFilterItems(List<CompetitionItem> items) {
  final now = DateTime.now();
  final openCount = items
      .where((item) => item.statusAt(now) == CompetitionStatus.registrationOpen)
      .length;
  final freeCount = items.where((item) => item.isFree).length;
  final linkCount = items.where((item) => item.hasRegistrationLink).length;

  return [
    _CompetitionFilterData(
      filter: CompetitionQuickFilter.all,
      label: 'همه ${PersianDigits.format(items.length)}',
      icon: Icons.grid_view_rounded,
    ),
    _CompetitionFilterData(
      filter: CompetitionQuickFilter.registrationOpen,
      label: 'ثبت‌نام باز ${PersianDigits.format(openCount)}',
      icon: Icons.how_to_reg_outlined,
    ),
    _CompetitionFilterData(
      filter: CompetitionQuickFilter.free,
      label: 'رایگان ${PersianDigits.format(freeCount)}',
      icon: Icons.money_off_csred_outlined,
    ),
    _CompetitionFilterData(
      filter: CompetitionQuickFilter.withRegistrationLink,
      label: 'لینک‌دار ${PersianDigits.format(linkCount)}',
      icon: Icons.link_rounded,
    ),
  ];
}

class _CompetitionsContent extends StatelessWidget {
  const _CompetitionsContent({required this.items});

  final List<CompetitionItem> items;

  @override
  Widget build(BuildContext context) {
    final featured = _pickFeatured(items);
    final rest = items.where((item) => item.id != featured.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FeaturedCompetitionCard(item: featured),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 16),
          _CompetitionsSectionHeader(totalCount: rest.length),
          const SizedBox(height: 10),
          for (var index = 0; index < rest.length; index++) ...[
            _CompetitionListCard(item: rest[index]),
            if (index != rest.length - 1) const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

CompetitionItem _pickFeatured(List<CompetitionItem> items) {
  final now = DateTime.now();
  return items.firstWhere(
    (item) => item.statusAt(now) == CompetitionStatus.registrationOpen,
    orElse: () => items.first,
  );
}

class _FeaturedCompetitionCard extends StatelessWidget {
  const _FeaturedCompetitionCard({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    const radius = 8.0;
    final status = item.statusAt(DateTime.now());

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => _showCompetitionDetails(context, item),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.softBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 158,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ArticleImage(
                      imageUrl: item.imageUrl,
                      featured: true,
                      borderRadius: 0,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 12,
                      top: 12,
                      child: _StatusBadge(status: status),
                    ),
                    PositionedDirectional(
                      end: 12,
                      top: 12,
                      child: _CategoryBadge(category: item.category),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      PersianDigits.format(item.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        PersianDigits.format(item.description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _CompetitionMetaGrid(item: item),
                    const SizedBox(height: 14),
                    _CompetitionPrimaryAction(item: item),
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

class _CompetitionListCard extends StatelessWidget {
  const _CompetitionListCard({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    const radius = 8.0;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => _showCompetitionDetails(context, item),
        child: Container(
          constraints: const BoxConstraints(minHeight: 154),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                height: 130,
                child: ArticleImage(imageUrl: item.imageUrl, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              Expanded(child: _CompetitionCardBody(item: item)),
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

class _CompetitionCardBody extends StatelessWidget {
  const _CompetitionCardBody({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.statusAt(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          textDirection: TextDirection.rtl,
          spacing: 7,
          runSpacing: 6,
          children: [
            _StatusBadge(status: status, compact: true),
            _CategoryBadge(category: item.category, compact: true),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          PersianDigits.format(item.title),
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
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            PersianDigits.format(item.description),
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
        _CompetitionCompactMeta(item: item),
        const SizedBox(height: 10),
        _CompetitionInlineAction(item: item),
      ],
    );
  }
}

class _CompetitionsSectionHeader extends StatelessWidget {
  const _CompetitionsSectionHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 3,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.royalBlueDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'سایر مسابقات',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              '${PersianDigits.format(totalCount)} مورد',
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompetitionPrimaryAction extends StatelessWidget {
  const _CompetitionPrimaryAction({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    if (item.hasRegistrationLink) {
      return FilledButton.icon(
        onPressed: () => _openCompetitionUrl(context, item),
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text('ورود به صفحه ثبت‌نام'),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showCompetitionDetails(context, item),
      icon: const Icon(Icons.info_outline_rounded, size: 18),
      label: const Text('مشاهده جزئیات'),
    );
  }
}

class _CompetitionInlineAction extends StatelessWidget {
  const _CompetitionInlineAction({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    final label = item.hasRegistrationLink ? 'ثبت‌نام' : 'جزئیات';
    final icon = item.hasRegistrationLink
        ? Icons.open_in_new_rounded
        : Icons.info_outline_rounded;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        height: 32,
        child: item.hasRegistrationLink
            ? FilledButton.icon(
                onPressed: () => _openCompetitionUrl(context, item),
                icon: Icon(icon, size: 15),
                label: Text(label),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: () => _showCompetitionDetails(context, item),
                icon: Icon(icon, size: 15),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      ),
    );
  }
}

class _CompetitionMetaGrid extends StatelessWidget {
  const _CompetitionMetaGrid({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    final items = _competitionMetaItems(item);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _CompetitionMetaItem(data: items[index])),
            if (index != items.length - 1)
              Container(width: 1, height: 38, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _CompetitionCompactMeta extends StatelessWidget {
  const _CompetitionCompactMeta({required this.item});

  final CompetitionItem item;

  @override
  Widget build(BuildContext context) {
    final registrationDeadline = item.registrationDeadline;
    final startDate = item.startDate;

    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 7,
      children: [
        _TinyMeta(
          icon: Icons.local_offer_outlined,
          label: _formatFee(item.amount),
        ),
        if (registrationDeadline != null)
          _TinyMeta(
            icon: Icons.event_note_outlined,
            label: PersianDateFormatter.format(registrationDeadline),
          ),
        if (startDate != null)
          _TinyMeta(
            icon: Icons.emoji_events_outlined,
            label: PersianDateFormatter.format(startDate),
          ),
      ],
    );
  }
}

class _TinyMeta extends StatelessWidget {
  const _TinyMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 13, color: AppColors.teal),
        const SizedBox(width: 4),
        Text(
          PersianDigits.format(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _CompetitionMetaItem extends StatelessWidget {
  const _CompetitionMetaItem({required this.data});

  final _CompetitionMetaData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: AppColors.teal, size: 18),
          const SizedBox(height: 6),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            PersianDigits.format(data.value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ink,
              fontSize: 10.8,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionMetaData {
  const _CompetitionMetaData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

List<_CompetitionMetaData> _competitionMetaItems(CompetitionItem item) {
  return [
    _CompetitionMetaData(
      icon: Icons.event_note_outlined,
      label: 'مهلت ثبت‌نام',
      value: item.registrationDeadline == null
          ? 'نامشخص'
          : PersianDateFormatter.format(item.registrationDeadline!),
    ),
    _CompetitionMetaData(
      icon: Icons.emoji_events_outlined,
      label: 'برگزاری',
      value: _formatDateRange(item.startDate, item.endDate),
    ),
    _CompetitionMetaData(
      icon: Icons.local_offer_outlined,
      label: 'هزینه',
      value: _formatFee(item.amount),
    ),
  ];
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.compact = false});

  final CompetitionStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      height: compact ? 22 : 26,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          competitionStatusLabel(status),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.foreground,
            fontSize: compact ? 10 : 10.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category, this.compact = false});

  final CompetitionCategory? category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 22 : 26,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xffeef4ff),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          competitionCategoryLabel(category),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.royalBlueDark,
            fontSize: compact ? 10 : 10.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _CompetitionsLoadingView extends StatelessWidget {
  const _CompetitionsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _CompetitionsTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _CompetitionsToolbarSkeleton(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: _CompetitionsSkeletonList(),
          ),
        ),
      ],
    );
  }
}

class _CompetitionsErrorView extends StatelessWidget {
  const _CompetitionsErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _CompetitionsTopBar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            child: AppStatePanel(
              icon: Icons.wifi_off_rounded,
              title: 'دریافت مسابقات ناموفق بود',
              body: 'ارتباط با سرویس مسابقات برقرار نشد. دوباره تلاش کنید.',
              actionLabel: 'تلاش دوباره',
              onAction: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCompetitionsPanel extends StatelessWidget {
  const _EmptyCompetitionsPanel({
    required this.query,
    required this.filter,
    required this.onClear,
  });

  final String query;
  final CompetitionQuickFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    final filterLabel = _filterLabel(filter);
    final body = trimmedQuery.isNotEmpty
        ? 'برای عبارت «$trimmedQuery» مسابقه‌ای در داده‌های فعلی پیدا نشد.'
        : filter == CompetitionQuickFilter.all
        ? 'در حال حاضر مسابقه‌ای برای نمایش وجود ندارد.'
        : 'در فیلتر «$filterLabel» مسابقه‌ای برای نمایش وجود ندارد.';

    return AppStatePanel(
      icon: Icons.search_off_rounded,
      title: 'مسابقه‌ای پیدا نشد',
      body: body,
      actionLabel: trimmedQuery.isEmpty && filter == CompetitionQuickFilter.all
          ? 'تلاش دوباره'
          : 'نمایش همه مسابقات',
      onAction: onClear,
    );
  }
}

class _CompetitionsToolbarSkeleton extends StatelessWidget {
  const _CompetitionsToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        ShimmerCard(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(child: ShimmerBlock(height: 14, radius: 7)),
              SizedBox(width: 12),
              ShimmerBlock(width: 20, height: 20, radius: 10),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            ShimmerBlock(width: 76, height: 38, radius: 19),
            SizedBox(width: 8),
            ShimmerBlock(width: 110, height: 38, radius: 19),
            SizedBox(width: 8),
            ShimmerBlock(width: 82, height: 38, radius: 19),
          ],
        ),
      ],
    );
  }
}

class _CompetitionsSkeletonList extends StatelessWidget {
  const _CompetitionsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerCard(
          height: 344,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ShimmerBlock(height: 158, radius: 0),
              SizedBox(height: 14),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: ShimmerBlock(height: 18, radius: 8),
              ),
              SizedBox(height: 9),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: FractionallySizedBox(
                  widthFactor: 0.72,
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBlock(height: 15, radius: 7),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: ShimmerBlock(height: 42, radius: 8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 5; i++) ...[
          const _CompetitionCardSkeleton(),
          if (i != 4) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CompetitionCardSkeleton extends StatelessWidget {
  const _CompetitionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      height: 154,
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBlock(width: 92, height: 130, radius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ShimmerBlock(width: 74, height: 22, radius: 11),
                    SizedBox(width: 7),
                    ShimmerBlock(width: 64, height: 22, radius: 11),
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
                Spacer(),
                ShimmerBlock(width: 72, height: 32, radius: 8),
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

Future<void> _showCompetitionDetails(
  BuildContext context,
  CompetitionItem item,
) {
  return CompetitionDetailsPage.open(context, item);
}

Future<void> _openCompetitionUrl(
  BuildContext context,
  CompetitionItem item,
) async {
  final rawUrl = item.competitionUrl?.trim();
  final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('لینک ثبت‌نام معتبر نیست.')));
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('امکان باز کردن لینک ثبت‌نام وجود ندارد.')),
    );
  }
}

String _formatDateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) {
    return 'نامشخص';
  }
  if (start != null && end != null) {
    if (_isSameDay(start, end)) {
      return PersianDateFormatter.format(start);
    }
    return '${PersianDateFormatter.format(start)} تا ${PersianDateFormatter.format(end)}';
  }
  return PersianDateFormatter.format(start ?? end!);
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatFee(int? amount) {
  if (amount == null) {
    return 'نامشخص';
  }
  if (amount <= 0) {
    return 'رایگان';
  }
  return '${_formatThousands(amount)} ریال';
}

String _formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

String _filterLabel(CompetitionQuickFilter filter) {
  return switch (filter) {
    CompetitionQuickFilter.all => 'همه',
    CompetitionQuickFilter.registrationOpen => 'ثبت‌نام باز',
    CompetitionQuickFilter.free => 'رایگان',
    CompetitionQuickFilter.withRegistrationLink => 'لینک‌دار',
  };
}

({Color foreground, Color background}) _statusColors(CompetitionStatus status) {
  return switch (status) {
    CompetitionStatus.registrationOpen => (
      foreground: const Color(0xff15713f),
      background: const Color(0xffdff7e6),
    ),
    CompetitionStatus.upcomingRegistration => (
      foreground: const Color(0xff20529f),
      background: const Color(0xffe2edff),
    ),
    CompetitionStatus.registrationClosed => (
      foreground: const Color(0xffa45500),
      background: const Color(0xffffedcc),
    ),
    CompetitionStatus.running => (
      foreground: const Color(0xff6941c6),
      background: const Color(0xffeee8ff),
    ),
    CompetitionStatus.ended => (
      foreground: const Color(0xff667789),
      background: const Color(0xffeef1f5),
    ),
    CompetitionStatus.inactive => (
      foreground: const Color(0xff9f2a1e),
      background: const Color(0xffffdfd9),
    ),
  };
}
