import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/mobile_page_header.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/event_item.dart';
import '../providers/events_providers.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  static const routeName = '/events';

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  late final TextEditingController _searchController;
  late final PageController _featuredController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(eventSearchQueryProvider),
    );
    _featuredController = PageController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(eventSearchQueryProvider, (previous, next) {
      if (next != _searchController.text) {
        _searchController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    final featuredEvents = ref.watch(featuredEventsProvider);
    final activeEvents = ref.watch(filteredEventsProvider);

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
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    const SliverToBoxAdapter(child: _EventsTopBar()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: _SearchAndFilters(controller: _searchController),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: _FeaturedEventCarousel(
                          controller: _featuredController,
                          events: featuredEvents,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _FeaturedDots(totalCount: featuredEvents.length),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _ActiveEventsHeader(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                        child: activeEvents.isEmpty
                            ? const _EmptyEventsPanel()
                            : _ActiveEventsList(events: activeEvents),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EventsTopBar extends StatelessWidget {
  const _EventsTopBar();

  @override
  Widget build(BuildContext context) {
    return const MobilePageHeader(
      title: 'مسابقات و رویدادها',
      subtitle: 'جدیدترین رویدادها، وبینارها و مسابقات',
    );
  }
}

class _SearchAndFilters extends ConsumerWidget {
  const _SearchAndFilters({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(eventSearchQueryProvider);

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: TextField(
            key: const ValueKey('events-search-field'),
            controller: controller,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            textAlignVertical: TextAlignVertical.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (value) {
              ref.read(eventSearchQueryProvider.notifier).setQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'جستجو در مسابقات و رویدادها...',
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
                        ref.read(eventSearchQueryProvider.notifier).clear();
                      },
                      icon: const Icon(Icons.close_rounded, size: 19),
                    ),
              prefixIconColor: AppColors.muted,
              suffixIconColor: AppColors.muted,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppColors.softBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppColors.softBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppColors.teal),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _CategoryScroller(),
      ],
    );
  }
}

class _CategoryScroller extends ConsumerWidget {
  const _CategoryScroller();

  static const _items = [
    _CategoryChipData(
      label: 'همه',
      icon: Icons.grid_view_rounded,
      category: null,
    ),
    _CategoryChipData(
      label: 'علمی',
      icon: Icons.science_outlined,
      category: EventCategory.science,
    ),
    _CategoryChipData(
      label: 'مهارتی',
      icon: Icons.business_center_outlined,
      category: EventCategory.skill,
    ),
    _CategoryChipData(
      label: 'هنری',
      icon: Icons.palette_outlined,
      category: EventCategory.art,
    ),
    _CategoryChipData(
      label: 'کارآفرینی',
      icon: Icons.rocket_launch_outlined,
      category: EventCategory.entrepreneurship,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedEventCategoryProvider);

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            for (var index = 0; index < _items.length; index++) ...[
              _CategoryChip(
                data: _items[index],
                selected: selectedCategory == _items[index].category,
                onTap: () {
                  ref
                      .read(selectedEventCategoryProvider.notifier)
                      .select(_items[index].category);
                },
              ),
              if (index != _items.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChipData {
  const _CategoryChipData({
    required this.label,
    required this.icon,
    required this.category,
  });

  final String label;
  final IconData icon;
  final EventCategory? category;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _CategoryChipData data;
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
          height: 34,
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

class _FeaturedEventCarousel extends ConsumerWidget {
  const _FeaturedEventCarousel({
    required this.controller,
    required this.events,
  });

  final PageController controller;
  final List<EventItem> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 188,
      child: PageView.builder(
        controller: controller,
        padEnds: false,
        itemCount: events.length,
        onPageChanged: (index) {
          ref.read(featuredEventIndexProvider.notifier).setIndex(index);
        },
        itemBuilder: (context, index) {
          return _FeaturedEventCard(event: events[index]);
        },
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff071b5c),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26071b5c),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xff07134e),
                  Color(0xff0b2370),
                  Color(0xff102f8d),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -20,
            top: 34,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 132,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: -18,
            bottom: 62,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 116,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.brightTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 13,
            top: 42,
            child: _HeroEventVisual(kind: event.visualKind),
          ),
          PositionedDirectional(
            start: 16,
            top: 12,
            child: _TagPill(
              label: event.typeLabel,
              foreground: Colors.white,
              background: const Color(0xff5946d8),
            ),
          ),
          PositionedDirectional(
            end: 16,
            top: 12,
            child: _TagPill(
              label: event.statusLabel,
              foreground: const Color(0xff0f5c32),
              background: const Color(0xffbff2c6),
            ),
          ),
          PositionedDirectional(
            top: 48,
            start: 16,
            end: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  PersianDigits.format(event.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    height: 1.34,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  PersianDigits.format(event.summary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 10,
            end: 10,
            bottom: 10,
            child: _EventMetaContainer(event: event),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _EventMetaContainer extends StatelessWidget {
  const _EventMetaContainer({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _EventMetaRow(
        event: event,
        iconColor: AppColors.royalBlueDark,
        valueColor: AppColors.muted,
        showDividers: true,
      ),
    );
  }
}

class _EventMetaRow extends StatelessWidget {
  const _EventMetaRow({
    required this.event,
    this.dense = false,
    this.showDividers = false,
    this.iconColor = AppColors.muted,
    this.labelColor = AppColors.muted,
    this.valueColor = AppColors.ink,
  });

  final EventItem event;
  final bool dense;
  final bool showDividers;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final items = _eventMetaItems(event, dense: dense);

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: _EventMetaItem(
              data: items[index],
              dense: dense,
              iconColor: iconColor,
              labelColor: labelColor,
              valueColor: valueColor,
            ),
          ),
          if (showDividers && index != items.length - 1)
            const _VerticalMetaDivider(),
        ],
      ],
    );
  }
}

class _EventMetaItem extends StatelessWidget {
  const _EventMetaItem({
    required this.data,
    required this.dense,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  final _EventMetaData data;
  final bool dense;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dense ? 2 : 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          Icon(data.icon, color: iconColor, size: dense ? 13 : 15),
          SizedBox(width: dense ? 3 : 5),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: dense ? 4 : 5),
                Text(
                  PersianDigits.format(data.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: valueColor,
                    fontSize: dense ? 10.5 : 10.8,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMetaData {
  const _EventMetaData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

List<_EventMetaData> _eventMetaItems(EventItem event, {required bool dense}) {
  return [
    _EventMetaData(
      icon: Icons.calendar_month_outlined,
      label: dense ? 'ثبت‌نام' : 'مهلت ثبت‌نام',
      value: PersianDateFormatter.format(event.registrationDeadline),
    ),
    _EventMetaData(
      icon: Icons.event_available_outlined,
      label: dense ? 'برگزاری' : 'تاریخ برگزاری',
      value: PersianDateFormatter.format(event.eventDate),
    ),
    _EventMetaData(
      icon: Icons.local_offer_outlined,
      label: 'هزینه',
      value: event.feeLabel,
    ),
  ];
}

class _VerticalMetaDivider extends StatelessWidget {
  const _VerticalMetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.softBorder);
  }
}

class _FeaturedDots extends ConsumerWidget {
  const _FeaturedDots({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (totalCount <= 1) {
      return const SizedBox(height: 20);
    }

    final activeIndex = ref.watch(featuredEventIndexProvider);

    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < totalCount; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: activeIndex == index ? 14 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: activeIndex == index
                    ? AppColors.brightTeal
                    : const Color(0xffd6dde4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveEventsHeader extends StatelessWidget {
  const _ActiveEventsHeader();

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
            'رویدادهای فعال',
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
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {},
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded, size: 16),
          label: const Text('مشاهده همه'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brightTeal,
            textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _ActiveEventsList extends StatelessWidget {
  const _ActiveEventsList({required this.events});

  final List<EventItem> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < events.length; index++) ...[
          _ActiveEventCard(event: events[index]),
          if (index != events.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActiveEventCard extends StatelessWidget {
  const _ActiveEventCard({required this.event});

  final EventItem event;

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
              _EventThumbnail(kind: event.visualKind),
              const SizedBox(width: 10),
              Expanded(child: _ActiveEventText(event: event)),
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

class _ActiveEventText extends StatelessWidget {
  const _ActiveEventText({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                PersianDigits.format(event.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(
              label: event.statusLabel,
              tone: event.statusTone,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          PersianDigits.format(event.summary),
          maxLines: 2,
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
        const SizedBox(height: 10),
        _EventMetaRow(
          event: event,
          dense: true,
          iconColor: AppColors.teal,
          labelColor: AppColors.muted,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.tone,
    this.compact = false,
  });

  final String label;
  final EventStatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(tone);

    return Container(
      height: compact ? 22 : 26,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          maxLines: 1,
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

({Color foreground, Color background}) _statusColors(EventStatusTone tone) {
  return switch (tone) {
    EventStatusTone.open => (
      foreground: const Color(0xff15713f),
      background: const Color(0xffdff7e6),
    ),
    EventStatusTone.upcoming => (
      foreground: const Color(0xffa45500),
      background: const Color(0xffffedcc),
    ),
    EventStatusTone.urgent => (
      foreground: const Color(0xff9f2a1e),
      background: const Color(0xffffdfd9),
    ),
  };
}

class _EmptyEventsPanel extends StatelessWidget {
  const _EmptyEventsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            color: AppColors.muted,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'رویدادی با این فیلتر پیدا نشد',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEventVisual extends StatelessWidget {
  const _HeroEventVisual({required this.kind});

  final EventVisualKind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 78,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 74,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff183477),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff5e8cf5), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 12,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          Positioned(
            left: 47,
            top: 0,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 33,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xff58a8ec),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Color(0xff173266),
                  size: 17,
                ),
              ),
            ),
          ),
          Positioned(
            left: 74,
            top: 24,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xffff7d23),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 58,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xffd8e4ff)),
                ),
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 4),
                child: Column(
                  children: [
                    Container(height: 3, color: const Color(0xffb6c6dd)),
                    const SizedBox(height: 5),
                    Container(height: 3, color: const Color(0xffd6dfeb)),
                    const SizedBox(height: 5),
                    Container(height: 3, color: const Color(0xffd6dfeb)),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 2,
            child: Icon(Icons.edit_rounded, color: Color(0xffffb145), size: 30),
          ),
        ],
      ),
    );
  }
}

class _EventThumbnail extends StatelessWidget {
  const _EventThumbnail({required this.kind});

  final EventVisualKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _thumbnailColors(kind),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            start: -14,
            top: 8,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 56,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -18,
            bottom: 10,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 58,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Center(child: _ThumbnailIcon(kind: kind)),
        ],
      ),
    );
  }
}

List<Color> _thumbnailColors(EventVisualKind kind) {
  return switch (kind) {
    EventVisualKind.video => [const Color(0xff17367c), const Color(0xff0e6aa5)],
    EventVisualKind.content => [
      const Color(0xff0d8278),
      const Color(0xff7ac7b0),
    ],
    EventVisualKind.finance => [
      const Color(0xffeef3f8),
      const Color(0xff9ac2df),
    ],
    EventVisualKind.science => [
      const Color(0xff42217d),
      const Color(0xff9a60b5),
    ],
    EventVisualKind.workshop => [
      const Color(0xff3751b5),
      const Color(0xfff08f3f),
    ],
  };
}

class _ThumbnailIcon extends StatelessWidget {
  const _ThumbnailIcon({required this.kind});

  final EventVisualKind kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      EventVisualKind.content => const _ContentThumbnail(),
      EventVisualKind.finance => const _FinanceThumbnail(),
      EventVisualKind.science => const _ScienceThumbnail(),
      EventVisualKind.workshop => const Icon(
        Icons.rocket_launch_rounded,
        color: Colors.white,
        size: 38,
      ),
      EventVisualKind.video => const Icon(
        Icons.play_circle_fill_rounded,
        color: Colors.white,
        size: 38,
      ),
    };
  }
}

class _ContentThumbnail extends StatelessWidget {
  const _ContentThumbnail();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 43,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xffec4e2f),
            size: 28,
          ),
        ),
        const Positioned(
          right: 2,
          top: 1,
          child: Icon(Icons.campaign_rounded, color: Colors.orange, size: 18),
        ),
        const Positioned(
          left: 1,
          bottom: 0,
          child: Icon(Icons.image_rounded, color: Color(0xff17367c), size: 16),
        ),
      ],
    );
  }
}

class _FinanceThumbnail extends StatelessWidget {
  const _FinanceThumbnail();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 11,
          child: Container(
            width: 46,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ChartBar(height: 9, color: Color(0xffec4e2f)),
                _ChartBar(height: 17, color: Color(0xff2b73d6)),
                _ChartBar(height: 23, color: Color(0xff12a26c)),
              ],
            ),
          ),
        ),
        const Positioned(
          bottom: 7,
          left: 15,
          child: Icon(
            Icons.calculate_rounded,
            color: Color(0xff17212d),
            size: 31,
          ),
        ),
      ],
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ScienceThumbnail extends StatelessWidget {
  const _ScienceThumbnail();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          left: 7,
          top: 8,
          child: Icon(
            Icons.bubble_chart_rounded,
            color: Color(0xffc876da),
            size: 25,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.biotech_rounded,
            color: Color(0xff2b286f),
            size: 34,
          ),
        ),
      ],
    );
  }
}
