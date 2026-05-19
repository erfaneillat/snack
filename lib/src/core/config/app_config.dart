class AppConfig {
  const AppConfig._();

  static const String apiHost = 'bpj.iau.ir';
  static const String newsListPath = '/api/v1/news/list';
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const int defaultNewsType = 0;

  static Uri newsListUri({
    int page = defaultPage,
    int pageSize = defaultPageSize,
    int type = defaultNewsType,
  }) {
    return Uri.https(apiHost, newsListPath, {
      'page': '$page',
      'pageSize': '$pageSize',
      'type': '$type',
    });
  }

  static Uri imageUri(String fileName) {
    return Uri.https(apiHost, '/Files/News/$fileName');
  }

  static Uri siteUri() {
    return Uri.https(apiHost);
  }
}
