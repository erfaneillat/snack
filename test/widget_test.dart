import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iran_university_portal/src/app/university_news_app.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_article.dart';
import 'package:iran_university_portal/src/features/news/domain/entities/news_feed.dart';
import 'package:iran_university_portal/src/features/news/domain/repositories/news_repository.dart';
import 'package:iran_university_portal/src/features/news/presentation/providers/news_providers.dart';

void main() {
  testWidgets('renders the RTL university news page', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('اخبار و اطلاعیه‌ها'), findsOneWidget);
    expect(find.textContaining('باشگاه پژوهشگران'), findsWidgets);
    expect(find.textContaining('طرح حامی'), findsWidgets);
    expect(find.byKey(const ValueKey('news-search-field')), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
  });

  testWidgets('filters news cards by query', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('news-search-field')),
      'نانو',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('رویدادهای نانو'), findsOneWidget);
    expect(find.textContaining('طرح حامی'), findsNothing);
  });

  testWidgets('fits a narrow phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('اخبار و اطلاعیه‌ها'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp() {
  return ProviderScope(
    overrides: [
      newsRepositoryProvider.overrideWithValue(const _FakeNewsRepository()),
    ],
    child: const UniversityNewsApp(),
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
