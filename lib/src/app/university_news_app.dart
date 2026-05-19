import 'package:flutter/material.dart';

import '../features/news/presentation/pages/news_page.dart';
import 'theme/app_theme.dart';

class UniversityNewsApp extends StatelessWidget {
  const UniversityNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'اخبار دانشگاه آزاد',
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const NewsPage(),
    );
  }
}
