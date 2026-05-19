import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.imageUrl,
    this.featured = false,
    this.borderRadius = 12,
  });

  final String? imageUrl;
  final bool featured;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: const Color(0xffe6eef1),
        child: imageUrl == null
            ? _ArticleImageFallback(featured: featured)
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _ArticleImageFallback(featured: featured, loading: true),
                errorWidget: (context, url, error) =>
                    _ArticleImageFallback(featured: featured),
              ),
      ),
    );
  }
}

class _ArticleImageFallback extends StatelessWidget {
  const _ArticleImageFallback({required this.featured, this.loading = false});

  final bool featured;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 74;
        final iconSize = featured ? 58.0 : (compact ? 28.0 : 40.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: featured ? 140 : 86,
                height: featured ? 140 : 86,
                decoration: const BoxDecoration(
                  color: Color(0xffc9dce1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: featured ? 86 : 54,
                height: featured ? 86 : 54,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.11),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading)
                    SizedBox(
                      width: compact ? 20 : 26,
                      height: compact ? 20 : 26,
                      child: const CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  else
                    Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.header,
                      size: iconSize,
                    ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'دانشگاه آزاد اسلامی',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.header,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
