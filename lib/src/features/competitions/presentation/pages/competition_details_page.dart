import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/shimmer.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_digits.dart';
import '../../domain/entities/competition_details.dart';
import '../../domain/entities/competition_item.dart';
import '../providers/competitions_providers.dart';
import '../../../news/presentation/widgets/article_image.dart';
import '../../../news/presentation/widgets/state_panels.dart';

class CompetitionDetailsPage extends ConsumerWidget {
  const CompetitionDetailsPage({
    super.key,
    required this.competitionId,
    this.initialCompetition,
  });

  final int competitionId;
  final CompetitionItem? initialCompetition;

  static Future<void> open(BuildContext context, CompetitionItem item) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompetitionDetailsPage(
          competitionId: item.id,
          initialCompetition: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(competitionDetailsProvider(competitionId));

    return _CompetitionDetailsFrame(
      child: detailsState.when(
        data: (details) => _CompetitionDetailsContent(details: details),
        loading: () =>
            _CompetitionDetailsLoading(initialCompetition: initialCompetition),
        error: (error, stackTrace) => _CompetitionDetailsError(
          onRetry: () =>
              ref.invalidate(competitionDetailsProvider(competitionId)),
        ),
      ),
    );
  }
}

class _CompetitionDetailsFrame extends StatelessWidget {
  const _CompetitionDetailsFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    children: [
                      const _CompetitionDetailsTopBar(),
                      Expanded(child: child),
                    ],
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

class _CompetitionDetailsTopBar extends StatelessWidget {
  const _CompetitionDetailsTopBar();

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
                'جزئیات مسابقه',
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

class _CompetitionDetailsContent extends StatelessWidget {
  const _CompetitionDetailsContent({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _CompetitionDetailsHeader(details: details),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: _CompetitionDetailsSections(details: details),
          ),
        ),
      ],
    );
  }
}

class _CompetitionDetailsHeader extends StatelessWidget {
  const _CompetitionDetailsHeader({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    final status = details.statusAt(DateTime.now());

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
        const SizedBox(height: 14),
        Wrap(
          textDirection: TextDirection.rtl,
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            _InfoChip(
              icon: Icons.verified_outlined,
              label: competitionStatusLabel(status),
              tint: _statusTint(status),
            ),
            _InfoChip(
              icon: Icons.category_outlined,
              label: competitionCategoryLabel(details.category),
              tint: AppColors.royalBlue,
            ),
            if (details.edition != null)
              _InfoChip(
                icon: Icons.workspace_premium_outlined,
                label: 'دوره ${PersianDigits.format(details.edition!)}',
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
        if (details.themes.isNotEmpty) ...[
          const SizedBox(height: 10),
          _TagWrap(items: details.themes),
        ],
        if (details.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          SelectableText(
            PersianDigits.format(details.description),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.9,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompetitionDetailsSections extends StatelessWidget {
  const _CompetitionDetailsSections({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SchedulePanel(details: details),
        const SizedBox(height: 12),
        _RegistrationPanel(details: details),
        if (details.secretariatAddress != null ||
            details.secretariatPhone != null) ...[
          const SizedBox(height: 12),
          _SecretariatPanel(details: details),
        ],
        if (details.scientificCommittee.isNotEmpty) ...[
          const SizedBox(height: 12),
          _PeoplePanel(
            title: 'کمیته علمی',
            icon: Icons.science_outlined,
            people: details.scientificCommittee,
          ),
        ],
        if (details.executiveCommittee.isNotEmpty) ...[
          const SizedBox(height: 12),
          _PeoplePanel(
            title: 'کمیته اجرایی',
            icon: Icons.groups_outlined,
            people: details.executiveCommittee,
          ),
        ],
        if (details.sponsors.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SimpleSection(
            title: 'حامیان',
            icon: Icons.handshake_outlined,
            child: _TagWrap(items: details.sponsors),
          ),
        ],
        if (details.summaryBody != null ||
            details.summaryAttachmentUrl != null ||
            details.competitionTemplate != null) ...[
          const SizedBox(height: 12),
          _SummaryPanel(details: details),
        ],
      ],
    );
  }
}

class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    return _SimpleSection(
      title: 'زمان‌بندی و شرایط',
      icon: Icons.event_note_outlined,
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'شروع ثبت‌نام',
            value: _formatDate(details.registrationStart),
          ),
          _DetailRow(
            icon: Icons.event_busy_outlined,
            label: 'پایان ثبت‌نام',
            value: _formatDate(details.registrationDeadline),
          ),
          _DetailRow(
            icon: Icons.emoji_events_outlined,
            label: 'بازه برگزاری',
            value: _formatDateRange(details.startDate, details.endDate),
          ),
          _DetailRow(
            icon: Icons.group_outlined,
            label: 'اعضای تیم',
            value: _formatTeamSize(
              details.minTeamMembers,
              details.maxTeamMembers,
            ),
          ),
          _DetailRow(
            icon: Icons.local_offer_outlined,
            label: 'هزینه',
            value: _formatFee(details.amount),
          ),
        ],
      ),
    );
  }
}

class _RegistrationPanel extends StatelessWidget {
  const _RegistrationPanel({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    return _SimpleSection(
      title: 'ثبت‌نام',
      icon: Icons.how_to_reg_outlined,
      child: details.hasRegistrationLink
          ? SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openUri(context, details.competitionUrl!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('ورود به صفحه ثبت‌نام'),
              ),
            )
          : Text(
              'برای این مسابقه لینک ثبت‌نام مستقیم ثبت نشده است. اطلاعات تماس و روش اعلام آمادگی را از توضیحات مسابقه دنبال کنید.',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.8,
              ),
            ),
    );
  }
}

class _SecretariatPanel extends StatelessWidget {
  const _SecretariatPanel({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    final phone = details.secretariatPhone;

    return _SimpleSection(
      title: 'دبیرخانه',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (details.secretariatAddress != null)
            _DetailRow(
              icon: Icons.map_outlined,
              label: 'نشانی',
              value: details.secretariatAddress!,
            ),
          if (phone != null)
            _DetailRow(
              icon: Icons.call_outlined,
              label: 'تلفن',
              value: phone,
              onTap: () => _openUri(context, 'tel:$phone'),
            ),
        ],
      ),
    );
  }
}

class _PeoplePanel extends StatelessWidget {
  const _PeoplePanel({
    required this.title,
    required this.icon,
    required this.people,
  });

  final String title;
  final IconData icon;
  final List<String> people;

  @override
  Widget build(BuildContext context) {
    return _SimpleSection(
      title: title,
      icon: icon,
      child: Column(
        children: [
          for (var index = 0; index < people.length; index++) ...[
            _PersonRow(name: people[index]),
            if (index != people.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.details});

  final CompetitionDetails details;

  @override
  Widget build(BuildContext context) {
    return _SimpleSection(
      title: 'خلاصه و فایل‌ها',
      icon: Icons.attachment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (details.summaryBody != null)
            Text(
              PersianDigits.format(details.summaryBody!),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.8,
              ),
            ),
          if (details.summaryAttachmentUrl != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openUri(context, details.summaryAttachmentUrl!),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('مشاهده پیوست خلاصه'),
            ),
          ],
          if (details.competitionTemplate != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.description_outlined,
              label: 'قالب مسابقه',
              value: details.competitionTemplate!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SimpleSection extends StatelessWidget {
  const _SimpleSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: AppColors.teal, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PersianDigits.format(value),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.teal,
            size: 17,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            PersianDigits.format(name),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: tint, size: 16),
          const SizedBox(width: 6),
          Text(
            PersianDigits.format(label),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tint,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              PersianDigits.format(item),
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _CompetitionDetailsLoading extends StatelessWidget {
  const _CompetitionDetailsLoading({this.initialCompetition});

  final CompetitionItem? initialCompetition;

  @override
  Widget build(BuildContext context) {
    final item = initialCompetition;

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
                    imageUrl: item?.imageUrl,
                    featured: true,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ShimmerBlock(width: 86, height: 32, radius: 8),
                    SizedBox(width: 8),
                    ShimmerBlock(width: 112, height: 32, radius: 8),
                  ],
                ),
                const SizedBox(height: 16),
                if (item == null)
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
                    PersianDigits.format(item.title),
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
                ShimmerBlock(height: 92, radius: 8),
                SizedBox(height: 12),
                ShimmerBlock(height: 154, radius: 8),
                SizedBox(height: 12),
                ShimmerBlock(height: 118, radius: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompetitionDetailsError extends StatelessWidget {
  const _CompetitionDetailsError({required this.onRetry});

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
              title: 'دریافت مسابقه ناموفق بود',
              body:
                  'جزئیات مسابقه دریافت نشد. اتصال را بررسی کنید و دوباره تلاش کنید.',
              actionLabel: 'تلاش دوباره',
              onAction: onRetry,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openUri(BuildContext context, String rawUri) async {
  final uri = Uri.tryParse(rawUri.trim());
  if (uri == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('پیوند معتبر نیست.')));
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('باز کردن پیوند ناموفق بود.')));
  }
}

String _formatDate(DateTime? date) {
  return date == null ? 'نامشخص' : PersianDateFormatter.format(date);
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

String _formatTeamSize(int? min, int? max) {
  if (min == null && max == null) {
    return 'نامشخص';
  }
  if (min != null && max != null) {
    if (min == max) {
      return '$min نفره';
    }
    return '$min تا $max نفر';
  }
  if (min != null) {
    return 'حداقل $min نفر';
  }
  return 'حداکثر $max نفر';
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

Color _statusTint(CompetitionStatus status) {
  return switch (status) {
    CompetitionStatus.registrationOpen => AppColors.teal,
    CompetitionStatus.upcomingRegistration => AppColors.royalBlue,
    CompetitionStatus.registrationClosed => AppColors.amber,
    CompetitionStatus.running => const Color(0xff6941c6),
    CompetitionStatus.ended => AppColors.muted,
    CompetitionStatus.inactive => AppColors.red,
  };
}
