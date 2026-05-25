import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iran_university_portal/src/app/theme/app_theme.dart';
import 'package:iran_university_portal/src/app/university_news_app.dart';
import 'package:iran_university_portal/src/features/competitions/data/models/competition_item_dto.dart';
import 'package:iran_university_portal/src/features/competitions/domain/entities/competition_details.dart';
import 'package:iran_university_portal/src/features/competitions/domain/entities/competition_feed.dart';
import 'package:iran_university_portal/src/features/competitions/domain/entities/competition_item.dart';
import 'package:iran_university_portal/src/features/competitions/domain/repositories/competitions_repository.dart';
import 'package:iran_university_portal/src/features/competitions/presentation/pages/competitions_page.dart';
import 'package:iran_university_portal/src/features/competitions/presentation/providers/competitions_providers.dart';
import 'package:iran_university_portal/src/features/events/domain/entities/event_item.dart';
import 'package:iran_university_portal/src/features/events/domain/repositories/events_repository.dart';
import 'package:iran_university_portal/src/features/events/presentation/pages/events_page.dart';
import 'package:iran_university_portal/src/features/events/presentation/providers/events_providers.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_details.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_article.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_feed.dart';
import 'package:iran_university_portal/src/features/news/domain/repositories/news_repository.dart';
import 'package:iran_university_portal/src/features/news/data/models/news_article_dto.dart';
import 'package:iran_university_portal/src/features/news/presentation/pages/news_page.dart';
import 'package:iran_university_portal/src/features/news/presentation/providers/news_providers.dart';
import 'package:iran_university_portal/src/features/weblog/data/models/weblog_post_dto.dart';
import 'package:iran_university_portal/src/features/weblog/domain/entities/weblog_details.dart';
import 'package:iran_university_portal/src/features/weblog/domain/entities/weblog_feed.dart';
import 'package:iran_university_portal/src/features/weblog/domain/entities/weblog_post.dart';
import 'package:iran_university_portal/src/features/weblog/domain/repositories/weblog_repository.dart';
import 'package:iran_university_portal/src/features/weblog/presentation/pages/weblog_page.dart';
import 'package:iran_university_portal/src/features/weblog/presentation/providers/weblog_providers.dart';

void main() {
  test('builds news image URLs from API image names', () {
    final firstArticle = NewsArticleDto.fromJson({
      'id': 1567,
      'title': 'خبر',
      'image': 'snhkhzgf.0qm.jpg',
    }).toEntity();
    final secondArticle = NewsArticleDto.fromJson({
      'id': 1526,
      'title': 'خبر',
      'image': 'm54fhgtw.wio.png',
    }).toEntity();

    expect(
      firstArticle.imageUrl,
      'https://bpj.iau.ir/uploads/snhkhzgf.0qm.jpg',
    );
    expect(
      secondArticle.imageUrl,
      'https://bpj.iau.ir/uploads/m54fhgtw.wio.png',
    );
  });

  test('builds weblog image URLs from API picture names', () {
    final post = WeblogPostDto.fromJson({
      'id': 136,
      'title': 'وبلاگ',
      'picture': 'sarfhbzr.tg1.jpg',
      'createdAt': '2025-07-26T12:17:59.1296654',
      'author': 'مدیر سایت',
      'link': '34TG61',
    }).toEntity();

    expect(post.imageUrl, 'https://bpj.iau.ir/uploads/sarfhbzr.tg1.jpg');
    expect(post.createdAt, DateTime(2025, 7, 26, 12, 17, 59, 129, 665));
    expect(post.author, 'مدیر سایت');
  });

  test('builds competition image URLs and strips HTML descriptions', () {
    final competition = CompetitionItemDto.fromJson({
      'id': 1943,
      'title': 'نبرد نبض ها',
      'description': '<p>مسابقه&nbsp;<strong>پرستاری</strong></p>',
      'isActive': true,
      'amount': 0,
      'registrationDeadline': '2026-05-26T00:00:00',
      'posterPath': 'iuak414l.g2d.jpg',
      'logoPath': 'srtqpmch.5yy.png',
    }).toEntity();

    expect(
      competition.posterUrl,
      'https://bpj.iau.ir/uploads/iuak414l.g2d.jpg',
    );
    expect(competition.logoUrl, 'https://bpj.iau.ir/uploads/srtqpmch.5yy.png');
    expect(competition.description, 'مسابقه پرستاری');
    expect(competition.category, CompetitionCategory.medical);
  });

  testWidgets('renders the RTL competitions page', (tester) async {
    await tester.pumpWidget(_competitionsTestApp());
    await tester.pumpAndSettle();

    expect(find.text('مسابقات فعال'), findsOneWidget);
    expect(find.textContaining('نبرد نبض ها'), findsOneWidget);
    expect(find.textContaining('Reading Stories Aloud'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('competitions-search-field')),
      findsOneWidget,
    );
    expect(
      Directionality.of(tester.element(find.text('مسابقات فعال'))),
      TextDirection.rtl,
    );
  });

  testWidgets('filters competition cards by query', (tester) async {
    await tester.pumpWidget(_competitionsTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('competitions-search-field')),
      'اسکرچ',
    );
    await tester.pumpAndSettle();

    expect(find.text('برنامه نویسی اسکرچ ویژه دانش آموزان'), findsOneWidget);
    expect(find.textContaining('Reading Stories Aloud'), findsNothing);
  });

  testWidgets('filters competition cards by free entry', (tester) async {
    await tester.pumpWidget(_competitionsTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('competition-filter-free')));
    await tester.pumpAndSettle();

    expect(find.text('نبرد نبض ها'), findsOneWidget);
    expect(find.textContaining('Reading Stories Aloud'), findsNothing);
  });

  testWidgets('shows connection error when the competitions request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _competitionsTestApp(repository: const _FailingCompetitionsRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('دریافت مسابقات ناموفق بود'), findsOneWidget);
    expect(
      find.textContaining('ارتباط با سرویس مسابقات برقرار نشد'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('competitions-search-field')),
      findsNothing,
    );
  });

  testWidgets('opens a competition details page with secretariat data', (
    tester,
  ) async {
    await tester.pumpWidget(_competitionsTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('نبرد نبض ها'));
    await tester.pumpAndSettle();

    expect(find.text('جزئیات مسابقه'), findsOneWidget);
    expect(
      find.textContaining('مسابقه ای با سوالات در زمینه پرستاری'),
      findsOneWidget,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('کمیته علمی'), findsOneWidget);
    expect(find.textContaining('خانم حمیده محسنی'), findsOneWidget);
    expect(find.textContaining('۰۷۱۵۲۲۵۱۰۰۲'), findsOneWidget);
    expect(find.text('ثبت‌نام'), findsOneWidget);
  });

  testWidgets('shows connection error when competition details request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _competitionsTestApp(
        repository: const _DetailsFailingCompetitionsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('نبرد نبض ها'));
    await tester.pumpAndSettle();

    expect(find.text('دریافت مسابقه ناموفق بود'), findsOneWidget);
    expect(find.textContaining('جزئیات مسابقه دریافت نشد'), findsOneWidget);
  });

  testWidgets('shows connection error when the events request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _eventsTestApp(repository: const _FailingEventsRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('دریافت رویدادها ناموفق بود'), findsOneWidget);
    expect(
      find.textContaining('ارتباط با سرویس رویدادها برقرار نشد'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('events-search-field')), findsNothing);
  });

  testWidgets('keeps events and adds competitions in bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);
    expect(find.byKey(const ValueKey('events-search-field')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-competitions')));
    await tester.pumpAndSettle();

    expect(find.text('مسابقات فعال'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('competitions-search-field')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('nav-news')));
    await tester.pumpAndSettle();

    expect(find.text('اخبار و اطلاعیه‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('news-search-field')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-events')));
    await tester.pumpAndSettle();

    expect(find.text('مسابقات و رویدادها'), findsOneWidget);
    expect(find.byKey(const ValueKey('events-search-field')), findsOneWidget);
  });

  testWidgets('switches to weblog from bottom navigation', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-weblog')));
    await tester.pumpAndSettle();

    expect(find.text('وبلاگ'), findsWidgets);
    expect(find.byKey(const ValueKey('weblog-search-field')), findsOneWidget);
    expect(find.textContaining('ربوکاپ آزاد ایران'), findsWidgets);
  });

  testWidgets('shows connection error when the news request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _newsTestApp(repository: const _FailingNewsRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('دریافت خبرها ناموفق بود'), findsOneWidget);
    expect(
      find.textContaining('ارتباط با سرویس خبری برقرار نشد'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('news-search-field')), findsNothing);
  });

  testWidgets('shows connection error when the weblog request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _weblogTestApp(repository: const _FailingWeblogRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('دریافت وبلاگ ناموفق بود'), findsOneWidget);
    expect(
      find.textContaining('ارتباط با سرویس وبلاگ برقرار نشد'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('weblog-search-field')), findsNothing);
  });

  testWidgets('searches weblog through the remote weblog endpoint', (
    tester,
  ) async {
    final repository = _SearchWeblogRepository();

    await tester.pumpWidget(_weblogTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('فرهیختگان جوان'), findsWidgets);
    expect(find.textContaining('ربوکاپ آزاد ایران'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('weblog-search-field')),
      'هوش مصنوعی',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(
      repository.searchRequests,
      contains((query: 'هوش مصنوعی', page: 1, pageSize: 20)),
    );
    expect(find.textContaining('حرکت ربات‌های ایرانی'), findsWidgets);
    expect(find.textContaining('فرهیختگان جوان'), findsNothing);
  });

  testWidgets('automatically requests the next weblog page in batches of 20', (
    tester,
  ) async {
    final repository = _PagedWeblogRepository();

    await tester.pumpWidget(_weblogTestApp(repository: repository));
    await tester.pumpAndSettle();

    expect(repository.requests, contains((page: 1, pageSize: 20)));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3200));
    await tester.pumpAndSettle();

    expect(repository.requests, contains((page: 2, pageSize: 20)));
  });

  testWidgets('opens a weblog details page with parsed article body', (
    tester,
  ) async {
    await tester.pumpWidget(_weblogTestApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.text(
        'هشتمین جشنواره ملی پروژه های دانش آموزی فرهیختگان جوان برگزار می شود',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('جزئیات مطلب'), findsOneWidget);
    expect(
      find.textContaining('باشگاه پژوهشگران جوان و نخبگان با همکاری'),
      findsOneWidget,
    );
    expect(find.text('مشاهده تصاویر'), findsOneWidget);
  });

  testWidgets('shows connection error when the weblog details request fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _weblogTestApp(repository: const _DetailsFailingWeblogRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.text(
        'هشتمین جشنواره ملی پروژه های دانش آموزی فرهیختگان جوان برگزار می شود',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دریافت مطلب ناموفق بود'), findsOneWidget);
    expect(find.textContaining('متن کامل مطلب دریافت نشد'), findsOneWidget);
  });

  testWidgets('filters news cards by type', (tester) async {
    await tester.pumpWidget(_newsTestApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('طرح حامی فاصله میان دانشجو'), findsOneWidget);
    expect(find.textContaining('منتخبین رویدادهای نانو'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('news-type-3')));
    await tester.pumpAndSettle();

    expect(find.textContaining('طرح حامی فاصله میان دانشجو'), findsNothing);
    expect(find.textContaining('منتخبین رویدادهای نانو'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('news-type-all')));
    await tester.pumpAndSettle();

    expect(find.textContaining('طرح حامی فاصله میان دانشجو'), findsOneWidget);
    expect(find.textContaining('منتخبین رویدادهای نانو'), findsOneWidget);
  });

  testWidgets('searches news through the remote news endpoint', (tester) async {
    final repository = _SearchNewsRepository();

    await tester.pumpWidget(_newsTestApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('news-search-field')),
      'جشنواره',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(
      repository.searchRequests,
      contains((query: 'جشنواره', page: 1, pageSize: 20, type: 0)),
    );
    expect(find.textContaining('جشنواره فرهیختگان جوان'), findsOneWidget);
    expect(find.textContaining('طرح حامی فاصله میان دانشجو'), findsNothing);
  });

  testWidgets('opens a news details page with parsed article body', (
    tester,
  ) async {
    await tester.pumpWidget(_newsTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('منتخبین رویدادهای نانو'));
    await tester.pumpAndSettle();

    expect(find.text('جزئیات خبر'), findsOneWidget);
    expect(
      find.textContaining('متن کامل خبر منتخبین رویدادهای نانو'),
      findsOneWidget,
    );
    expect(find.textContaining('۲۱۸ بازدید'), findsOneWidget);
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

  testWidgets('shows connection error when the next news page fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _newsTestApp(repository: _SecondPageFailingNewsRepository()),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3200));
    await tester.pumpAndSettle();

    expect(find.text('دریافت خبرها ناموفق بود'), findsOneWidget);
    expect(
      find.textContaining('ارتباط با سرویس خبری برقرار نشد'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('news-search-field')), findsNothing);
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

Widget _testApp({
  CompetitionsRepository competitionsRepository =
      const _FakeCompetitionsRepository(),
  NewsRepository newsRepository = const _FakeNewsRepository(),
  EventsRepository eventsRepository = const _FakeEventsRepository(),
  WeblogRepository weblogRepository = const _FakeWeblogRepository(),
}) {
  return ProviderScope(
    overrides: [
      competitionsRepositoryProvider.overrideWithValue(competitionsRepository),
      newsRepositoryProvider.overrideWithValue(newsRepository),
      eventsRepositoryProvider.overrideWithValue(eventsRepository),
      weblogRepositoryProvider.overrideWithValue(weblogRepository),
    ],
    child: const UniversityNewsApp(),
  );
}

Widget _competitionsTestApp({
  CompetitionsRepository repository = const _FakeCompetitionsRepository(),
}) {
  return ProviderScope(
    overrides: [competitionsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const CompetitionsPage(),
    ),
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

Widget _eventsTestApp({
  EventsRepository repository = const _FakeEventsRepository(),
}) {
  return ProviderScope(
    overrides: [eventsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const EventsPage(),
    ),
  );
}

Widget _weblogTestApp({
  WeblogRepository repository = const _FakeWeblogRepository(),
}) {
  return ProviderScope(
    overrides: [weblogRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const WeblogPage(),
    ),
  );
}

class _FakeCompetitionsRepository implements CompetitionsRepository {
  const _FakeCompetitionsRepository();

  @override
  Future<CompetitionFeed> getCompetitions({
    int page = 1,
    int pageSize = 20,
    bool onlyActive = true,
  }) async {
    return CompetitionFeed(
      page: page,
      pageSize: pageSize,
      totalCount: _testCompetitions.length,
      loadedAt: DateTime(2026, 5, 25),
      items: _testCompetitions,
    );
  }

  @override
  Future<CompetitionDetails> getCompetitionDetails({required int id}) async {
    return _competitionDetailsFor(id);
  }
}

class _FailingCompetitionsRepository implements CompetitionsRepository {
  const _FailingCompetitionsRepository();

  @override
  Future<CompetitionFeed> getCompetitions({
    int page = 1,
    int pageSize = 20,
    bool onlyActive = true,
  }) async {
    throw StateError('Connection error');
  }

  @override
  Future<CompetitionDetails> getCompetitionDetails({required int id}) async {
    throw StateError('Connection error');
  }
}

class _DetailsFailingCompetitionsRepository
    extends _FakeCompetitionsRepository {
  const _DetailsFailingCompetitionsRepository();

  @override
  Future<CompetitionDetails> getCompetitionDetails({required int id}) async {
    throw StateError('Connection error');
  }
}

class _FakeEventsRepository implements EventsRepository {
  const _FakeEventsRepository();

  @override
  Future<List<EventItem>> getEvents({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    return _testEvents;
  }
}

class _FailingEventsRepository implements EventsRepository {
  const _FailingEventsRepository();

  @override
  Future<List<EventItem>> getEvents({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    throw StateError('Connection error');
  }
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
          newsType: 1,
        ),
        NewsArticle(
          id: 2,
          title: 'منتخبین رویدادهای نانو به سوی صنعت هدایت می شوند',
          publishDate: DateTime(2025, 11, 23),
          linkCode: '66WE85',
          newsType: 3,
        ),
      ],
    );
  }

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 1,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        NewsArticle(
          id: 3,
          title: 'نتایج جستجو برای $query',
          publishDate: DateTime(2026, 5, 19),
          linkCode: 'SEARCH',
          newsType: type,
        ),
      ],
    );
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    return _newsDetailsFor(id);
  }
}

class _FailingNewsRepository implements NewsRepository {
  const _FailingNewsRepository();

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    throw StateError('Connection error');
  }

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    throw StateError('Connection error');
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    throw StateError('Connection error');
  }
}

class _FakeWeblogRepository implements WeblogRepository {
  const _FakeWeblogRepository();

  @override
  Future<WeblogFeed> getPosts({int page = 1, int pageSize = 20}) async {
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 2,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        WeblogPost(
          id: 136,
          title:
              'هشتمین جشنواره ملی پروژه های دانش آموزی فرهیختگان جوان برگزار می شود',
          summary: 'گزارش کوتاه از برنامه جشنواره فرهیختگان جوان',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 26, 12, 17),
          linkCode: '34TG61',
        ),
        WeblogPost(
          id: 135,
          title: 'اختتامیه نوزدهمین دوره مسابقات ربوکاپ آزاد ایران',
          summary: 'نوزدهمین دوره مسابقات ربوکاپ آزاد ایران',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 26, 11, 52),
          linkCode: '73VM16',
        ),
      ],
    );
  }

  @override
  Future<WeblogFeed> searchPosts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 1,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        WeblogPost(
          id: 137,
          title: 'نتایج جستجوی وبلاگ برای $query',
          summary: 'خلاصه نتیجه جستجو',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 27),
          linkCode: 'BLOGSEARCH',
        ),
      ],
    );
  }

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    return _weblogDetailsFor(id);
  }
}

class _FailingWeblogRepository implements WeblogRepository {
  const _FailingWeblogRepository();

  @override
  Future<WeblogFeed> getPosts({int page = 1, int pageSize = 20}) async {
    throw StateError('Connection error');
  }

  @override
  Future<WeblogFeed> searchPosts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    throw StateError('Connection error');
  }

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    throw StateError('Connection error');
  }
}

class _DetailsFailingWeblogRepository extends _FakeWeblogRepository {
  const _DetailsFailingWeblogRepository();

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    throw StateError('Connection error');
  }
}

class _PagedWeblogRepository implements WeblogRepository {
  final List<({int page, int pageSize})> requests = [];

  @override
  Future<WeblogFeed> getPosts({int page = 1, int pageSize = 20}) async {
    requests.add((page: page, pageSize: pageSize));
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 40,
      loadedAt: DateTime(2026, 5, 19),
      items: List.generate(pageSize, (index) {
        final number = ((page - 1) * pageSize) + index + 1;
        return WeblogPost(
          id: number,
          title: 'مطلب وبلاگ شماره $number',
          summary: 'خلاصه مطلب شماره $number',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 26),
          linkCode: 'BLOG$number',
        );
      }),
    );
  }

  @override
  Future<WeblogFeed> searchPosts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return getPosts(page: page, pageSize: pageSize);
  }

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    return _weblogDetailsFor(id);
  }
}

class _SearchWeblogRepository implements WeblogRepository {
  final List<({String query, int page, int pageSize})> searchRequests = [];

  @override
  Future<WeblogFeed> getPosts({int page = 1, int pageSize = 20}) async {
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 2,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        WeblogPost(
          id: 136,
          title:
              'هشتمین جشنواره ملی پروژه های دانش آموزی فرهیختگان جوان برگزار می شود',
          summary: 'گزارش کوتاه از برنامه جشنواره فرهیختگان جوان',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 26, 12, 17),
          linkCode: '34TG61',
        ),
        WeblogPost(
          id: 135,
          title: 'اختتامیه نوزدهمین دوره مسابقات ربوکاپ آزاد ایران',
          summary: 'نوزدهمین دوره مسابقات ربوکاپ آزاد ایران',
          author: 'مدیر سایت',
          createdAt: DateTime(2025, 7, 26, 11, 52),
          linkCode: '73VM16',
        ),
      ],
    );
  }

  @override
  Future<WeblogFeed> searchPosts({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    searchRequests.add((query: query, page: page, pageSize: pageSize));
    return WeblogFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 1,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        WeblogPost(
          id: 122,
          title: 'حرکت ربات‌های ایرانی به سمت هلند',
          summary:
              'بوکاپ فرصتی برای محک زدن توانمندی تیم‌های دانشجویی و دانش‌آموزی در حوزه رباتیک و هوش مصنوعی است.',
          author: 'مدیر سایت',
          createdAt: DateTime(2024, 9, 9, 8, 59),
          linkCode: '83DO62',
        ),
      ],
    );
  }

  @override
  Future<WeblogDetails> getPostDetails({required int id}) async {
    return _weblogDetailsFor(id);
  }
}

WeblogDetails _weblogDetailsFor(int id) {
  final isRobocup = id == 135;
  return WeblogDetails(
    id: id,
    title: isRobocup
        ? 'اختتامیه نوزدهمین دوره مسابقات ربوکاپ آزاد ایران'
        : 'هشتمین جشنواره ملی پروژه های دانش آموزی فرهیختگان جوان برگزار می شود',
    bodyHtml: isRobocup
        ? '<p>متن کامل اختتامیه نوزدهمین دوره مسابقات ربوکاپ آزاد ایران.</p>'
        : '<p><strong>باشگاه پژوهشگران جوان و نخبگان با همکاری معاونت علوم تربیتی و مهارتی دانشگاه آزاد اسلامی، هشتمین جشنواره ملی پروژه های دانش آموزی را برگزار می نماید.</strong></p><h3><a href="https://bpj.iau.ir/gallery/1046/test">گزارش تصویری جشنواره</a></h3>',
    metaDescription: isRobocup
        ? 'نوزدهمین دوره مسابقات ربوکاپ آزاد ایران'
        : 'هشتمین جشنواره پروژه های دانش آموزی فرهیختگان جوان برگزار شد',
    author: 'مدیر سایت',
    imageUrl: 'https://bpj.iau.ir/uploads/sarfhbzr.tg1.jpg',
    tags: 'جشنواره,فرهیختگان جوان',
    linkCode: isRobocup ? '73VM16' : '34TG61',
    createdAt: DateTime(2025, 7, 26, 12, 17),
  );
}

class _SearchNewsRepository implements NewsRepository {
  final List<({String query, int page, int pageSize, int type})>
  searchRequests = [];

  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 1,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        NewsArticle(
          id: 1,
          title: 'طرح حامی فاصله میان دانشجو و ساختار اداری را کاهش داد',
          publishDate: DateTime(2026, 5, 11),
          linkCode: '33FW56',
          newsType: 1,
        ),
      ],
    );
  }

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    searchRequests.add((
      query: query,
      page: page,
      pageSize: pageSize,
      type: type,
    ));
    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 1,
      loadedAt: DateTime(2026, 5, 19),
      items: [
        NewsArticle(
          id: 1458,
          title:
              'مراسم قدردانی از تیم اجرایی دانشجویی فعال در برگزاری هفتمین جشنواره فرهیختگان جوان برگزار شد',
          publishDate: DateTime(2025, 6, 2),
          linkCode: '23AU76',
          newsType: type,
        ),
      ],
    );
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    return _newsDetailsFor(id);
  }
}

class _SecondPageFailingNewsRepository implements NewsRepository {
  @override
  Future<NewsFeed> getNews({
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    if (page > 1) {
      throw StateError('Connection error');
    }

    return NewsFeed(
      page: page,
      pageSize: pageSize,
      totalCount: 40,
      loadedAt: DateTime(2026, 5, 19),
      items: List.generate(pageSize, (index) {
        final number = index + 1;
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

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    throw StateError('Connection error');
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    return _newsDetailsFor(id);
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

  @override
  Future<NewsFeed> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20,
    int type = 0,
  }) async {
    return getNews(page: page, pageSize: pageSize, type: type);
  }

  @override
  Future<NewsDetails> getNewsDetails({required int id}) async {
    return _newsDetailsFor(id);
  }
}

NewsDetails _newsDetailsFor(int id) {
  final isNano = id == 2;
  return NewsDetails(
    id: id,
    title: isNano
        ? 'منتخبین رویدادهای نانو به سوی صنعت هدایت می شوند'
        : 'طرح حامی فاصله میان دانشجو و ساختار اداری را کاهش داد',
    bodyHtml: isNano
        ? '<p>متن کامل خبر منتخبین رویدادهای نانو برای نمایش در صفحه جزئیات.</p>'
        : '<p>متن کامل خبر طرح حامی برای نمایش در صفحه جزئیات.</p>',
    linkCode: isNano ? '66WE85' : '33FW56',
    newsType: isNano ? 3 : 1,
    visitCount: isNano ? 218 : 118,
    publishDate: isNano ? DateTime(2025, 11, 23) : DateTime(2026, 5, 11),
  );
}

CompetitionDetails _competitionDetailsFor(int id) {
  final item = _testCompetitions.firstWhere(
    (competition) => competition.id == id,
    orElse: () => _testCompetitions.first,
  );

  if (id != 1943) {
    return CompetitionDetails(
      id: item.id,
      title: item.title,
      description: item.description,
      isActive: item.isActive,
      amount: item.amount,
      registrationStart: item.registrationStart,
      registrationDeadline: item.registrationDeadline,
      startDate: item.startDate,
      endDate: item.endDate,
      posterUrl: item.posterUrl,
      competitionUrl: item.competitionUrl,
      category: item.category,
    );
  }

  return CompetitionDetails(
    id: 1943,
    title: 'نبرد نبض ها',
    description:
        'باسلام مسابقه ای با سوالات در زمینه پرستاری بصورت آنلاین برگزار می گردد. اطلاع رسانی در پیام رسان بله با ID: @mosabegheh05 انجام می گردد.',
    isActive: true,
    amount: 0,
    themes: const ['پرستاری', 'تقویت دانش پرستاری'],
    edition: 1,
    maxTeamMembers: 1,
    minTeamMembers: 1,
    registrationStart: DateTime(2026, 5, 19),
    registrationDeadline: DateTime(2099, 5, 26),
    startDate: DateTime(2099, 5, 28),
    endDate: DateTime(2099, 5, 31),
    scientificCommittee: const ['خانم حمیده محسنی', 'خانم فاطمه جورکش'],
    executiveCommittee: const ['خانم نیایش فرصت', 'خانم یاسمن شعبانی'],
    secretariatAddress:
        'لار- بلوار دادمان- دانشگاه آزاد اسلامی لارستان - دانشکده علوم پزشکی - انجمن علمی پرستاری',
    secretariatPhone: '07152251002',
    posterUrl: 'https://bpj.iau.ir/uploads/iuak414l.g2d.jpg',
    logoUrl: 'https://bpj.iau.ir/uploads/srtqpmch.5yy.png',
    sponsors: const ['انجمن علمی پرستاری'],
    category: CompetitionCategory.medical,
  );
}

final _testCompetitions = List<CompetitionItem>.unmodifiable([
  CompetitionItem(
    id: 1943,
    title: 'نبرد نبض ها',
    description: 'مسابقه آنلاین با سوالات تخصصی در زمینه پرستاری',
    isActive: true,
    amount: 0,
    registrationStart: DateTime(2026, 5, 19),
    registrationDeadline: DateTime(2099, 5, 26),
    startDate: DateTime(2099, 5, 28),
    endDate: DateTime(2099, 5, 31),
    posterUrl: 'https://bpj.iau.ir/uploads/iuak414l.g2d.jpg',
    category: CompetitionCategory.medical,
  ),
  CompetitionItem(
    id: 1942,
    title: 'Reading Stories Aloud',
    description: 'خواندن داستان انگلیسی با بیان روان و تلفظ درست',
    isActive: true,
    amount: 1,
    registrationStart: DateTime(2026, 5, 23),
    registrationDeadline: DateTime(2099, 5, 26),
    startDate: DateTime(2099, 5, 27),
    endDate: DateTime(2099, 5, 31),
    posterUrl: 'https://bpj.iau.ir/uploads/t4oeqag0.0v2.jpg',
    category: CompetitionCategory.language,
  ),
  CompetitionItem(
    id: 1936,
    title: 'برنامه نویسی اسکرچ ویژه دانش آموزان',
    description: 'ساخت بازی و انیمیشن با برنامه نویسی اسکرچ',
    isActive: true,
    amount: 0,
    registrationStart: DateTime(2026, 5, 11),
    registrationDeadline: DateTime(2099, 5, 22),
    startDate: DateTime(2099, 5, 27),
    endDate: DateTime(2099, 5, 27),
    posterUrl: 'https://bpj.iau.ir/uploads/dwjes01p.wcq.png',
    competitionUrl: 'https://izeh.iau.ir/bpj/fa/form/11/test',
    category: CompetitionCategory.technology,
  ),
  CompetitionItem(
    id: 1761,
    title: 'رقابت بین حسابداران',
    description: 'مسابقه گروهی برای دانشجویان حسابداری',
    isActive: true,
    amount: 0,
    registrationStart: DateTime(2026, 1, 31),
    registrationDeadline: DateTime(2026, 2, 16),
    startDate: DateTime(2026, 2, 18),
    endDate: DateTime(2026, 2, 18),
    posterUrl: 'https://bpj.iau.ir/uploads/t1hbbjuo.ase.jpg',
    competitionUrl: 'https://bpj.iau.ir/competition/reghabathesabdaran',
    category: CompetitionCategory.business,
  ),
]);

final _testEvents = List<EventItem>.unmodifiable([
  EventItem(
    id: 1001,
    title: 'ترجمه محتوای ویدیو کلیپ (گفتاری به نوشتاری)',
    summary:
        'مسابقه ترجمه محتوای ویدیویی کوتاه ویژه اعضای فعال انجمن‌های علمی و استعدادهای برتر',
    category: EventCategory.skill,
    typeLabel: 'مسابقه',
    statusLabel: 'ثبت‌نام باز',
    statusTone: EventStatusTone.open,
    registrationDeadline: DateTime(2025, 4, 26),
    eventDate: DateTime(2025, 5, 4),
    feeLabel: 'رایگان',
    visualKind: EventVisualKind.video,
    featured: true,
  ),
  EventItem(
    id: 1002,
    title: 'چالش ایده‌پردازی کسب‌وکارهای دانشجویی',
    summary:
        'وبینار و رقابت کوتاه برای تبدیل ایده‌های دانشگاهی به مدل کسب‌وکار قابل ارائه',
    category: EventCategory.entrepreneurship,
    typeLabel: 'چالش',
    statusLabel: 'ظرفیت محدود',
    statusTone: EventStatusTone.urgent,
    registrationDeadline: DateTime(2025, 5, 2),
    eventDate: DateTime(2025, 5, 10),
    feeLabel: 'رایگان',
    visualKind: EventVisualKind.workshop,
    featured: true,
  ),
  EventItem(
    id: 2001,
    title: 'مسابقه تولید محتوا',
    summary: 'به مناسبت روز معلم و استاد',
    category: EventCategory.skill,
    typeLabel: 'مسابقه',
    statusLabel: 'ثبت‌نام باز',
    statusTone: EventStatusTone.open,
    registrationDeadline: DateTime(2025, 4, 26),
    eventDate: DateTime(2025, 5, 4),
    feeLabel: 'رایگان',
    visualKind: EventVisualKind.content,
  ),
  EventItem(
    id: 2002,
    title: 'رقابت بین حسابداران',
    summary: 'مسابقه گروهی برای دانشجویان حسابداری',
    category: EventCategory.skill,
    typeLabel: 'رقابت',
    statusLabel: 'ثبت‌نام باز',
    statusTone: EventStatusTone.open,
    registrationDeadline: DateTime(2025, 4, 26),
    eventDate: DateTime(2025, 5, 5),
    feeLabel: 'رایگان',
    visualKind: EventVisualKind.finance,
  ),
  EventItem(
    id: 2003,
    title: 'جشنواره مسابقات علمی و هنری میکروبیولوژی',
    summary: 'ویژه دانشجویان و دانش‌آموزان مقاطع تحصیلی',
    category: EventCategory.science,
    typeLabel: 'جشنواره',
    statusLabel: 'به‌زودی',
    statusTone: EventStatusTone.upcoming,
    registrationDeadline: DateTime(2025, 5, 10),
    eventDate: DateTime(2025, 5, 14),
    feeLabel: 'رایگان',
    visualKind: EventVisualKind.science,
  ),
]);
