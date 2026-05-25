import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/shimmer.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../../news/presentation/widgets/article_image.dart';
import '../../../news/presentation/widgets/article_meta_chip.dart';
import '../../../news/presentation/widgets/state_panels.dart';
import '../../domain/entities/weblog_details.dart';
import '../../domain/entities/weblog_post.dart';
import '../providers/weblog_providers.dart';

class WeblogDetailsPage extends ConsumerWidget {
  const WeblogDetailsPage({super.key, required this.postId, this.initialPost});

  final int postId;
  final WeblogPost? initialPost;

  static Future<void> open(BuildContext context, WeblogPost post) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WeblogDetailsPage(postId: post.id, initialPost: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(weblogDetailsProvider(postId));

    return _WeblogDetailsFrame(
      child: detailsState.when(
        data: (details) => _WeblogDetailsContent(details: details),
        loading: () => _WeblogDetailsLoading(initialPost: initialPost),
        error: (error, stackTrace) => _WeblogDetailsError(
          onRetry: () => ref.invalidate(weblogDetailsProvider(postId)),
        ),
      ),
    );
  }
}

class _WeblogDetailsFrame extends StatelessWidget {
  const _WeblogDetailsFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    const _WeblogDetailsTopBar(),
                    Expanded(child: child),
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

class _WeblogDetailsTopBar extends StatelessWidget {
  const _WeblogDetailsTopBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.softBorder)),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.ink,
            ),
            Expanded(
              child: Text(
                'جزئیات مطلب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _WeblogDetailsContent extends StatelessWidget {
  const _WeblogDetailsContent({required this.details});

  final WeblogDetails details;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _WeblogDetailsHeader(details: details),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            child: WeblogArticleBody(bodyHtml: details.bodyHtml),
          ),
        ),
      ],
    );
  }
}

class _WeblogDetailsHeader extends StatelessWidget {
  const _WeblogDetailsHeader({required this.details});

  final WeblogDetails details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 218,
          child: ArticleImage(
            imageUrl: details.imageUrl,
            featured: true,
            borderRadius: 8,
          ),
        ),
        if (details.createdAt != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              ArticleMetaChip(
                icon: Icons.calendar_month_outlined,
                label: PersianDateFormatter.format(details.createdAt!),
                tint: AppColors.teal,
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Text(
          PersianDigits.format(details.title),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.45,
          ),
        ),
        if (_hasMeaningfulText(details.metaDescription)) ...[
          const SizedBox(height: 10),
          Text(
            PersianDigits.format(details.metaDescription!.trim()),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.7,
            ),
          ),
        ],
      ],
    );
  }
}

class WeblogArticleBody extends StatelessWidget {
  const WeblogArticleBody({super.key, required this.bodyHtml});

  final String bodyHtml;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseWeblogBody(bodyHtml);
    if (blocks.isEmpty) {
      return AppStatePanel(
        icon: Icons.article_outlined,
        title: 'متن مطلب در دسترس نیست',
        body: 'برای این مطلب هنوز متن کامل ثبت نشده است.',
        actionLabel: 'بازگشت',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }

    return Column(
      key: const ValueKey('weblog-detail-body'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          _WeblogBodyBlockView(block: blocks[index]),
          if (index != blocks.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _WeblogBodyBlockView extends StatelessWidget {
  const _WeblogBodyBlockView({required this.block});

  final _WeblogBodyBlock block;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: block.prominent ? AppColors.header : AppColors.ink,
      fontSize: block.heading ? 16.5 : 15.5,
      fontWeight: block.heading || block.prominent
          ? FontWeight.w800
          : FontWeight.w500,
      height: block.heading ? 1.75 : 1.95,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          PersianDigits.format(block.text),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: textStyle,
        ),
        if (block.links.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              for (final link in block.links)
                OutlinedButton.icon(
                  onPressed: () => _openLink(context, link.uri),
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: Text(link.displayLabel),
                ),
            ],
          ),
        ],
      ],
    );

    if (!block.prominent && !block.heading) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: block.heading ? AppColors.surface : AppColors.amberSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: block.heading ? AppColors.softBorder : const Color(0xffffe5a3),
        ),
      ),
      child: content,
    );
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('باز کردن پیوند ناموفق بود')),
      );
    }
  }
}

class _WeblogDetailsLoading extends StatelessWidget {
  const _WeblogDetailsLoading({this.initialPost});

  final WeblogPost? initialPost;

  @override
  Widget build(BuildContext context) {
    final post = initialPost;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 218,
                  child: ArticleImage(
                    imageUrl: post?.imageUrl,
                    featured: true,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBlock(width: 102, height: 32, radius: 8),
                ),
                const SizedBox(height: 16),
                if (post == null)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ShimmerBlock(height: 20, radius: 8),
                      SizedBox(height: 10),
                      FractionallySizedBox(
                        widthFactor: 0.76,
                        alignment: AlignmentDirectional.centerStart,
                        child: ShimmerBlock(height: 20, radius: 8),
                      ),
                    ],
                  )
                else
                  Text(
                    PersianDigits.format(post.title),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.45,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerBlock(height: 15, radius: 7),
                SizedBox(height: 11),
                ShimmerBlock(height: 15, radius: 7),
                SizedBox(height: 11),
                ShimmerBlock(height: 15, radius: 7),
                SizedBox(height: 11),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBlock(height: 15, radius: 7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeblogDetailsError extends StatelessWidget {
  const _WeblogDetailsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            child: AppStatePanel(
              icon: Icons.wifi_off_rounded,
              title: 'دریافت مطلب ناموفق بود',
              body:
                  'متن کامل مطلب دریافت نشد. اتصال را بررسی کنید و دوباره تلاش کنید.',
              actionLabel: 'تلاش دوباره',
              onAction: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}

List<_WeblogBodyBlock> _parseWeblogBody(String value) {
  final document = html_parser.parse(value);
  final body = document.body;
  if (body == null) {
    return const [];
  }

  final elements = body.querySelectorAll('p,h1,h2,h3,h4,li,blockquote');
  final sourceNodes = elements.isEmpty
      ? body.nodes
      : elements.cast<html_dom.Node>();

  return [for (final node in sourceNodes) ?_blockFromNode(node)];
}

_WeblogBodyBlock? _blockFromNode(html_dom.Node node) {
  final text = _normalizeBodyText(node.text);
  if (text.isEmpty) {
    return null;
  }

  final element = node is html_dom.Element ? node : null;
  final links = element == null ? const <_WeblogBodyLink>[] : _linksIn(element);
  final tagName = element?.localName?.toLowerCase() ?? '';
  final html = element?.outerHtml.toLowerCase() ?? '';
  final heading = tagName.startsWith('h');
  final prominent =
      links.isNotEmpty ||
      element?.querySelector('strong,b') != null ||
      html.contains('#c0392b');

  return _WeblogBodyBlock(
    text: text,
    links: links,
    heading: heading,
    prominent: prominent,
  );
}

List<_WeblogBodyLink> _linksIn(html_dom.Element element) {
  return [
    for (final anchor in element.querySelectorAll('a'))
      ?_linkFromAnchor(anchor),
  ];
}

_WeblogBodyLink? _linkFromAnchor(html_dom.Element anchor) {
  final href = anchor.attributes['href']?.trim();
  if (href == null || href.isEmpty) {
    return null;
  }

  final uri = _resolveUri(href);
  if (uri == null) {
    return null;
  }

  final label = _normalizeBodyText(anchor.text);
  return _WeblogBodyLink(uri: uri, label: label);
}

Uri? _resolveUri(String href) {
  final normalizedHref = _normalizeHref(href);
  final parsed = Uri.tryParse(normalizedHref);
  if (parsed == null) {
    return null;
  }
  if (parsed.hasScheme) {
    return parsed;
  }
  if (normalizedHref.startsWith('/')) {
    return Uri.https(AppConfig.apiHost, normalizedHref);
  }
  return Uri.https(AppConfig.apiHost, '/$normalizedHref');
}

String _normalizeHref(String value) {
  var href = value.replaceAll('\u00a0', '').trim();
  if (href.startsWith('http://https://') || href.startsWith('http://http://')) {
    href = href.substring('http://'.length);
  }
  return href;
}

String _normalizeBodyText(String? value) {
  return (value ?? '')
      .replaceAll('\u00a0', ' ')
      .replaceAll('\u200c', '')
      .replaceAll(RegExp(r'[ \t\r\n]+'), ' ')
      .trim();
}

bool _hasMeaningfulText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

class _WeblogBodyBlock {
  const _WeblogBodyBlock({
    required this.text,
    required this.links,
    required this.heading,
    required this.prominent,
  });

  final String text;
  final List<_WeblogBodyLink> links;
  final bool heading;
  final bool prominent;
}

class _WeblogBodyLink {
  const _WeblogBodyLink({required this.uri, required this.label});

  final Uri uri;
  final String label;

  String get displayLabel {
    if (uri.path.startsWith('/gallery/')) {
      return 'مشاهده تصاویر';
    }
    if (label.isEmpty || label.length <= 4) {
      return 'مشاهده پیوند';
    }
    return PersianDigits.format(label);
  }
}
