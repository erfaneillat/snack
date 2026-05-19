import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/university_news_app.dart';

void main() {
  runApp(const ProviderScope(child: UniversityNewsApp()));
}
