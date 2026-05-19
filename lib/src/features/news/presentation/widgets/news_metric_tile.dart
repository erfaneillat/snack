import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class NewsMetricTile extends StatelessWidget {
  const NewsMetricTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.dark = false,
  });

  final String value;
  final String label;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppColors.ink;
    final secondary = dark ? const Color(0xffc9dce5) : AppColors.muted;

    return Container(
      constraints: const BoxConstraints(minWidth: 136),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.15) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: dark ? Colors.white : AppColors.teal, size: 22),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
