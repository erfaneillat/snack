class AppConfig {
  const AppConfig._();

  static const String apiHost = 'bpj.iau.ir';
  static const String uploadsBaseUrl = 'https://bpj.iau.ir/uploads/';
  static const String newsListPath = '/api/v1/news/list';
  static const String newsSearchPath = '/api/v1/news/search';
  static const String newsDetailsPath = '/api/v1/news/get';
  static const String weblogListPath = '/api/v1/weblog/list';
  static const String weblogSearchPath = '/api/v1/weblog/search';
  static const String weblogDetailsPath = '/api/v1/weblog/get';
  static const String eventsListPath = '/api/v1/events/list';
  static const String competitionListPath = '/api/v1/competition/list';
  static const String competitionDetailsPath = '/api/v1/competition/get';
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const int defaultNewsType = 0;
  static const int defaultEventsType = 0;

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

  static Uri newsSearchUri({
    required String query,
    int page = defaultPage,
    int pageSize = defaultPageSize,
    int type = defaultNewsType,
  }) {
    return Uri.https(apiHost, newsSearchPath, {
      'q': query,
      'page': '$page',
      'pageSize': '$pageSize',
      'type': '$type',
    });
  }

  static Uri newsDetailsUri({required int id}) {
    return Uri.https(apiHost, newsDetailsPath, {'id': '$id'});
  }

  static Uri weblogListUri({
    int page = defaultPage,
    int pageSize = defaultPageSize,
  }) {
    return Uri.https(apiHost, weblogListPath, {
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Uri weblogSearchUri({
    required String query,
    int page = defaultPage,
    int pageSize = defaultPageSize,
  }) {
    return Uri.https(apiHost, weblogSearchPath, {
      'q': query,
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Uri weblogDetailsUri({required int id}) {
    return Uri.https(apiHost, weblogDetailsPath, {'id': '$id'});
  }

  static Uri imageUri(String fileName) {
    final value = fileName.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return uri;
    }

    var path = value;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.startsWith('uploads/')) {
      path = path.substring('uploads/'.length);
    }

    return Uri.parse('$uploadsBaseUrl$path');
  }

  static Uri eventsListUri({
    int page = defaultPage,
    int pageSize = defaultPageSize,
    int type = defaultEventsType,
  }) {
    return Uri.https(apiHost, eventsListPath, {
      'page': '$page',
      'pageSize': '$pageSize',
      'type': '$type',
    });
  }

  static Uri competitionListUri({
    int page = defaultPage,
    int pageSize = defaultPageSize,
    bool onlyActive = true,
  }) {
    return Uri.https(apiHost, competitionListPath, {
      'page': '$page',
      'pageSize': '$pageSize',
      'onlyActive': '$onlyActive',
    });
  }

  static Uri competitionDetailsUri({required int id}) {
    return Uri.https(apiHost, competitionDetailsPath, {'id': '$id'});
  }

  static Uri siteUri() {
    return Uri.https(apiHost);
  }
}
