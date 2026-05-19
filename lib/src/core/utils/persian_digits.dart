class PersianDigits {
  const PersianDigits._();

  static const List<String> _digits = [
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹',
  ];

  static String format(Object value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\d'),
      (match) => _digits[int.parse(match.group(0)!)],
    );
  }
}
