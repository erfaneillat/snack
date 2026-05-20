import 'package:flutter/material.dart';

import '../features/events/presentation/pages/events_page.dart';
import '../features/news/presentation/pages/news_page.dart';
import 'main_navigation_page.dart';
import 'theme/app_theme.dart';

class UniversityNewsApp extends StatelessWidget {
  const UniversityNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مسابقات و رویدادهای دانشگاه آزاد',
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        EventsPage.routeName: (context) => const EventsPage(),
        NewsPage.routeName: (context) => const NewsPage(),
      },
      home: const MainNavigationPage(),
    );
  }
}
