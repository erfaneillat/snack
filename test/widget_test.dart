import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iran_university_portal/src/app/theme/app_theme.dart';
import 'package:iran_university_portal/src/app/university_news_app.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_article.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_feed.dart';
import 'package:iran_university_portal/src/features/news/domain/repositories/news_repository.dart';
import 'package:iran_university_portal/src/features/news/presentation/pages/news_page.dart';
import 'package:iran_university_portal/src/features/news/presentation/providers/news_providers.dart';

void main() {
  testWidgets('renders the RTL competitions and events page', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);
    expect(find.textContaining('ترجمه محتوای ویدیو کلیپ'), findsOneWidget);
    expect(find.textContaining('مسابقه تولید محتوا'), findsOneWidget);
    expect(find.byKey(const ValueKey('events-search-field')), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('مسابقات و رویدادها'))),
      TextDirection.rtl,
    );
  });

  testWidgets('filters event cards by query', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('events-search-field')),
      'حسابداران',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('رقابت بین حسابداران'), findsOneWidget);
    expect(find.textContaining('مسابقه تولید محتوا'), findsNothing);
  });

  testWidgets('filters event cards by category', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('علمی'));
    await tester.pumpAndSettle();

    expect(find.textContaining('میکروبیولوژی'), findsOneWidget);
    expect(find.textContaining('رقابت بین حسابداران'), findsNothing);
  });

  testWidgets('switches between events and news from bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-news')));
    await tester.pumpAndSettle();

    expect(find.text('اخبار و اطلاعیه‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('news-search-field')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-events')));
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);
    expect(find.byKey(const ValueKey('events-search-field')), findsOneWidget);
  });

  testWidgets('automatically requests the next news page in batches of 20', (
    tester,
  ) async {
    final repository = _PagedNewsRepository();

    await tester.pumpWidget(_newsTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(repository.requests, contains((page: 1, pageSize: 20)));
    expect(find.text('بارگذاری بیشتر'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3200));
    await tester.pumpAndSettle();

    expect(repository.requests, contains((page: 2, pageSize: 20)));
  });

  testWidgets('fits a narrow phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp({NewsRepository repository = const _FakeNewsRepository()}) {
  return ProviderScope(
    overrides: [newsRepositoryProvider.overrideWithValue(repository)],
    child: const UniversityNewsApp(),
  );
}

Widget _newsTestApp({NewsRepository repository = const _FakeNewsRepository()}) {
  return ProviderScope(
    overrides: [newsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const NewsPage(),
    ),
  );
}

class _FakeNewsRepository implements NewsRepository {
  const _FakeNewsRepository();

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 2,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        NewsArticle(
          id: 1,
          title: 'طرح حامی فاصله میان دانشجو و ساختار اداری را کاهش داد',
          publishDate: DateTime(2026, 5, 11),
          linkCode: '33FW56',
          newsType: type,
        ),
        NewsArticle(
          id: 2,
          title: 'منتخبین رویدادهای نانو به سوی صنعت هدایت می شوند',
          publishDate: DateTime(2025, 11, 23),
          linkCode: '66WE85',
          newsType: type,
        ),
      ],
    );
  }
}

class _PagedNewsRepository implements NewsRepository {
  final List<({int page, int pageSize})> requests = [];

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    requests.add((page: page, pageSize: pageSize));
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 40,
      loadedAt: DateTime(2026, 5, 19),
      items: List.generate(pageSize, (index) {
        final number = ((page - 1) * pageSize) + index + 1;
        return NewsArticle(
          id: number,
          title: 'خبر شماره $number',
          publishDate: DateTime(2026, 5, 19),
          linkCode: 'NEWS$number',
          newsType: type,
        );
      }),
    );
  }
}
