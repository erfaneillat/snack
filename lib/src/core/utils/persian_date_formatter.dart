import 'package:shamsi_date/shamsi_date.dart';

import 'persian_digits.dart';

class PersianDateFormatter {
  const PersianDateFormatter._();

  static String format(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${PersianDigits.format(jalali.day)} ${jalali.formatter.mN} ${PersianDigits.format(jalali.year)}';
  }
}
