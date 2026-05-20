import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/persian_digits.dart';
import '../providers/news_providers.dart';

class NewsToolbar extends ConsumerStatefulWidget {
  const NewsToolbar({
    super.key,
    required this.totalCount,
    required this.enabled,
  });

  final int? totalCount;
  final bool enabled;

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
    final allLabel = widget.totalCount == null
        ? 'همه'
        : 'همه ${PersianDigits.format(widget.totalCount.toString())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: TextField(
            key: const ValueKey('news-search-field'),
            controller: _controller,
            enabled: widget.enabled,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
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
              _ToolbarChip(label: allLabel, icon: Icons.grid_view_rounded),
              const SizedBox(width: 8),
              const _ToolbarChip(
                label: 'خبر رسمی',
                icon: Icons.verified_outlined,
                selected: false,
              ),
              const SizedBox(width: 8),
              const _ToolbarChip(
                label: 'رویدادها',
                icon: Icons.event_available_outlined,
                selected: false,
              ),
              const SizedBox(width: 8),
              const _ToolbarChip(
                label: 'اطلاعیه‌ها',
                icon: Icons.campaign_outlined,
                selected: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({
    required this.label,
    required this.icon,
    this.selected = true,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.royalBlueDark;
    final background = selected ? AppColors.teal : AppColors.surface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
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
    );
  }
}
