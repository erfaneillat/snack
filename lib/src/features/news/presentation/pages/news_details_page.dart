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
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_details.dart';
import '../providers/news_providers.dart';
import '../widgets/article_image.dart';
import '../widgets/article_meta_chip.dart';
import '../widgets/news_toolbar.dart';
import '../widgets/state_panels.dart';

class NewsDetailsPage extends ConsumerWidget {
  const NewsDetailsPage({
    super.key,
    required this.articleId,
    this.initialArticle,
  });

  final int articleId;
  final NewsArticle? initialArticle;

  static Future<void> open(BuildContext context, NewsArticle article) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            NewsDetailsPage(articleId: article.id, initialArticle: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(newsDetailsProvider(articleId));

    return _NewsDetailsFrame(
      child: detailsState.when(
        data: (details) => _NewsDetailsContent(details: details),
        loading: () => _NewsDetailsLoading(initialArticle: initialArticle),
        error: (error, stackTrace) => _NewsDetailsError(
          onRetry: () => ref.invalidate(newsDetailsProvider(articleId)),
        ),
      ),
    );
  }
}

class _NewsDetailsFrame extends StatelessWidget {
  const _NewsDetailsFrame({required this.child});

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
                    const _NewsDetailsTopBar(),
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

class _NewsDetailsTopBar extends StatelessWidget {
  const _NewsDetailsTopBar();

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
                'جزئیات خبر',
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

class _NewsDetailsContent extends StatelessWidget {
  const _NewsDetailsContent({required this.details});

  final NewsDetails details;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _NewsDetailsHeader(details: details),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            child: ArticleBody(bodyHtml: details.bodyHtml),
          ),
        ),
      ],
    );
  }
}

class _NewsDetailsHeader extends StatelessWidget {
  const _NewsDetailsHeader({required this.details});

  final NewsDetails details;

  @override
  Widget build(BuildContext context) {
    final publishDate = details.publishDate;

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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            ArticleMetaChip(
              icon: Icons.article_outlined,
              label: newsTypeLabel(details.newsType),
              tint: AppColors.teal,
            ),
            if (publishDate != null)
              ArticleMetaChip(
                icon: Icons.calendar_month_outlined,
                label: PersianDateFormatter.format(publishDate),
                tint: AppColors.teal,
              ),
            ArticleMetaChip(
              icon: Icons.visibility_outlined,
              label: '${PersianDigits.format(details.visitCount)} بازدید',
              tint: AppColors.amber,
            ),
          ],
        ),
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

class ArticleBody extends StatelessWidget {
  const ArticleBody({super.key, required this.bodyHtml});

  final String bodyHtml;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseArticleBody(bodyHtml);
    if (blocks.isEmpty) {
      return AppStatePanel(
        icon: Icons.article_outlined,
        title: 'متن خبر در دسترس نیست',
        body: 'برای این خبر هنوز متن کامل ثبت نشده است.',
        actionLabel: 'بازگشت',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }

    return Column(
      key: const ValueKey('news-detail-body'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          _ArticleParagraph(block: blocks[index]),
          if (index != blocks.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ArticleParagraph extends StatelessWidget {
  const _ArticleParagraph({required this.block});

  final _ArticleBodyBlock block;

  @override
  Widget build(BuildContext context) {
    final text = SelectableText(
      PersianDigits.format(block.text),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: block.highlighted ? AppColors.header : AppColors.ink,
        fontSize: 15.5,
        fontWeight: block.highlighted ? FontWeight.w800 : FontWeight.w500,
        height: 1.95,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text,
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

    if (!block.highlighted) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffffe5a3)),
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

class _NewsDetailsLoading extends StatelessWidget {
  const _NewsDetailsLoading({this.initialArticle});

  final NewsArticle? initialArticle;

  @override
  Widget build(BuildContext context) {
    final article = initialArticle;

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
                    imageUrl: article?.imageUrl,
                    featured: true,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ShimmerBlock(width: 74, height: 32, radius: 8),
                    SizedBox(width: 8),
                    ShimmerBlock(width: 102, height: 32, radius: 8),
                  ],
                ),
                const SizedBox(height: 16),
                if (article == null)
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
                    PersianDigits.format(article.title),
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

class _NewsDetailsError extends StatelessWidget {
  const _NewsDetailsError({required this.onRetry});

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
              title: 'دریافت خبر ناموفق بود',
              body:
                  'متن کامل خبر دریافت نشد. اتصال را بررسی کنید و دوباره تلاش کنید.',
              actionLabel: 'تلاش دوباره',
              onAction: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}

List<_ArticleBodyBlock> _parseArticleBody(String value) {
  final document = html_parser.parse(value);
  final body = document.body;
  if (body == null) {
    return const [];
  }

  final paragraphs = body.querySelectorAll('p');
  final sourceBlocks = paragraphs.isEmpty
      ? body.nodes
      : paragraphs.cast<html_dom.Node>();

  return [for (final node in sourceBlocks) ?_blockFromNode(node)];
}

_ArticleBodyBlock? _blockFromNode(html_dom.Node node) {
  final text = _normalizeBodyText(node.text);
  if (text.isEmpty) {
    return null;
  }

  final element = node is html_dom.Element ? node : null;
  final links = element == null
      ? const <_ArticleBodyLink>[]
      : _linksIn(element);
  final html = element?.outerHtml.toLowerCase() ?? '';
  final highlighted =
      links.isNotEmpty ||
      element?.querySelector('strong,b') != null ||
      html.contains('#c0392b');

  return _ArticleBodyBlock(text: text, links: links, highlighted: highlighted);
}

List<_ArticleBodyLink> _linksIn(html_dom.Element element) {
  return [
    for (final anchor in element.querySelectorAll('a'))
      ?_linkFromAnchor(anchor),
  ];
}

_ArticleBodyLink? _linkFromAnchor(html_dom.Element anchor) {
  final href = anchor.attributes['href']?.trim();
  if (href == null || href.isEmpty) {
    return null;
  }

  final uri = _resolveUri(href);
  if (uri == null) {
    return null;
  }

  final label = _normalizeBodyText(anchor.text);
  return _ArticleBodyLink(uri: uri, label: label);
}

Uri? _resolveUri(String href) {
  final parsed = Uri.tryParse(href);
  if (parsed == null) {
    return null;
  }
  if (parsed.hasScheme) {
    return parsed;
  }
  if (href.startsWith('/')) {
    return Uri.https(AppConfig.apiHost, href);
  }
  return Uri.https(AppConfig.apiHost, '/$href');
}

String _normalizeBodyText(String? value) {
  return (value ?? '')
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'[ \t\r\n]+'), ' ')
      .trim();
}

bool _hasMeaningfulText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

class _ArticleBodyBlock {
  const _ArticleBodyBlock({
    required this.text,
    required this.links,
    required this.highlighted,
  });

  final String text;
  final List<_ArticleBodyLink> links;
  final bool highlighted;
}

class _ArticleBodyLink {
  const _ArticleBodyLink({required this.uri, required this.label});

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
