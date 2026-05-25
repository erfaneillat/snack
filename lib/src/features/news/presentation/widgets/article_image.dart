import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/shimmer.dart';
import '../../../../core/network/dio_provider.dart';

final _articleImageBytesProvider = FutureProvider.autoDispose
    .family<Uint8List, String>((ref, imageUrl) async {
      final response = await ref
          .watch(imageDioProvider)
          .getUri<List<int>>(
            Uri.parse(imageUrl),
            options: Options(
              responseType: ResponseType.bytes,
              validateStatus: (_) => true,
            ),
          );

      final statusCode = response.statusCode ?? 0;
      final contentType = response.headers.value(Headers.contentTypeHeader);
      if (statusCode < 200 || statusCode >= 300) {
        throw StateError('Invalid image response: $statusCode $contentType');
      }

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw StateError('Empty image response');
      }

      final bytes = Uint8List.fromList(data);
      final isImageContentType =
          contentType?.toLowerCase().startsWith('image/') ?? false;
      if (!isImageContentType && !_looksLikeSupportedImage(bytes)) {
        throw StateError('Invalid image response: $statusCode $contentType');
      }

      if (!_looksLikeSupportedImage(bytes)) {
        throw StateError('Unsupported image bytes');
      }

      return bytes;
    });

bool _looksLikeSupportedImage(Uint8List bytes) {
  if (bytes.length < 12) {
    return false;
  }

  final isJpeg = bytes[0] == 0xff && bytes[1] == 0xd8;
  final isPng =
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47;
  final isGif =
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38;
  final isWebP =
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50;

  return isJpeg || isPng || isGif || isWebP;
}

class ArticleImage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = imageUrl == null
        ? null
        : ref.watch(_articleImageBytesProvider(imageUrl!));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: const Color(0xffe6eef1),
        child:
            imageState?.when(
              data: (bytes) => Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    _ArticleImageFallback(featured: featured),
              ),
              loading: () =>
                  _ArticleImageFallback(featured: featured, loading: true),
              error: (error, stackTrace) =>
                  _ArticleImageFallback(featured: featured),
            ) ??
            _ArticleImageFallback(featured: featured),
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
        final compact = constraints.maxHeight < 86 || constraints.maxWidth < 86;
        final iconSize = featured ? 58.0 : (compact ? 28.0 : 40.0);
        final showLabel = featured || !compact;

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
                    ShimmerBlock(
                      width: compact ? 28 : 42,
                      height: compact ? 28 : 42,
                      radius: compact ? 14 : 21,
                      color: Colors.white.withValues(alpha: 0.56),
                    )
                  else
                    Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.header,
                      size: iconSize,
                    ),
                  if (showLabel) ...[
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
