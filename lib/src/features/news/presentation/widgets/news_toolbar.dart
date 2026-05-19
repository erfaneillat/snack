import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: TextField(
            key: const ValueKey('news-search-field'),
            controller: _controller,
            enabled: widget.enabled,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (value) {
              ref.read(newsSearchQueryProvider.notifier).setQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'جستجو در اخبار...',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: IconButton(
                tooltip: query.isEmpty ? 'جستجو' : 'پاک کردن',
                onPressed: query.isEmpty ? null : _clear,
                icon: Icon(
                  query.isEmpty ? Icons.search_rounded : Icons.close_rounded,
                  size: 18,
                ),
              ),
              suffixIconColor: AppColors.muted,
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: _ToolbarChip(label: 'همه', selected: true)),
            SizedBox(width: 8),
            Expanded(child: _ToolbarChip(label: 'خبر رسمی')),
            SizedBox(width: 8),
            Expanded(child: _ToolbarChip(label: 'رویدادها')),
            SizedBox(width: 8),
            Expanded(child: _ToolbarChip(label: 'اطلاعیه‌ها')),
          ],
        ),
      ],
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.royalBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.royalBlue : AppColors.softBorder,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x220c4aa2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
