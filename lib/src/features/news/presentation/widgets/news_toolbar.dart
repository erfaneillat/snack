import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/news_article.dart';
import '../providers/news_providers.dart';

class NewsToolbar extends ConsumerStatefulWidget {
  const NewsToolbar({
    super.key,
    required this.totalCount,
    required this.enabled,
    this.articles = const [],
  });

  final int? totalCount;
  final bool enabled;
  final List<NewsArticle> articles;

  @override
  ConsumerState<NewsToolbar> createState() => _NewsToolbarState();
}

class _NewsToolbarState extends ConsumerState<NewsToolbar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(newsSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(newsSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(newsSearchQueryProvider, (previous, next) {
      if (next != _controller.text) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    final query = ref.watch(newsSearchQueryProvider);
    final selectedType = ref.watch(selectedNewsTypeProvider);
    final typeOptions = _buildNewsTypeOptions(widget.articles);
    final allLabel = widget.totalCount == null
        ? 'همه'
        : 'همه ${PersianDigits.format(widget.totalCount.toString())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            key: const ValueKey('news-search-field'),
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
              ref.read(newsSearchQueryProvider.notifier).setQuery(value);
            },
            onSubmitted: (value) {
              ref.read(newsSearchQueryProvider.notifier).submit(value);
            },
            decoration: InputDecoration(
              hintText: 'جستجو در اخبار و اطلاعیه‌ها...',
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
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              _ToolbarChip(
                key: const ValueKey('news-type-all'),
                label: allLabel,
                icon: Icons.grid_view_rounded,
                selected: selectedType == null,
                enabled: widget.enabled,
                onTap: () {
                  ref.read(selectedNewsTypeProvider.notifier).clear();
                },
              ),
              for (final option in typeOptions) ...[
                const SizedBox(width: 8),
                _ToolbarChip(
                  key: ValueKey('news-type-${option.type}'),
                  label:
                      '${option.label} ${PersianDigits.format(option.count)}',
                  icon: option.icon,
                  selected: selectedType == option.type,
                  enabled: widget.enabled,
                  onTap: () {
                    ref
                        .read(selectedNewsTypeProvider.notifier)
                        .select(option.type);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

List<_NewsTypeOption> _buildNewsTypeOptions(List<NewsArticle> articles) {
  final counts = <int, int>{};
  for (final article in articles) {
    if (article.newsType <= 0) {
      continue;
    }
    counts.update(article.newsType, (count) => count + 1, ifAbsent: () => 1);
  }

  final unknownTypes =
      counts.keys
          .where((type) => !_knownNewsTypeIcons.containsKey(type))
          .toList()
        ..sort();
  final orderedTypes = [
    ..._knownNewsTypeIcons.keys.where(counts.containsKey),
    ...unknownTypes,
  ];

  return [
    for (final type in orderedTypes)
      _NewsTypeOption(
        type: type,
        count: counts[type]!,
        label: newsTypeLabel(type),
        icon: _knownNewsTypeIcons[type] ?? Icons.article_outlined,
      ),
  ];
}

String newsTypeLabel(int type) {
  return switch (type) {
    0 => 'خبر',
    1 => 'خبر رسمی',
    2 => 'رویدادها',
    3 => 'اطلاعیه‌ها',
    _ => 'دسته ${PersianDigits.format(type)}',
  };
}

const Map<int, IconData> _knownNewsTypeIcons = {
  1: Icons.verified_outlined,
  2: Icons.event_available_outlined,
  3: Icons.campaign_outlined,
};

class _NewsTypeOption {
  const _NewsTypeOption({
    required this.type,
    required this.count,
    required this.label,
    required this.icon,
  });

  final int type;
  final int count;
  final String label;
  final IconData icon;
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = true,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.royalBlueDark;
    final background = selected ? AppColors.teal : AppColors.surface;

    return Tooltip(
      message: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.58,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled && !selected ? onTap : null,
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
                  Icon(icon, color: foreground, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
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
        ),
      ),
    );
  }
}
