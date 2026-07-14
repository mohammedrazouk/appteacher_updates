import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'en').format(date);
  }

  static String formatArabic(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
}
