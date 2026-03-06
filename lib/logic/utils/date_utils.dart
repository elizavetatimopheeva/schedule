import 'package:intl/intl.dart';

class DateUtils {
  static DateTime parseDate(String dateStr) {
    return DateFormat('dd.MM.yyyy').parse(dateStr);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static DateTime getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static String getRussianDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      default:
        return 'Воскресенье';
    }
  }

  static int getWeekdayNumber(String dayName) {
    switch (dayName) {
      case 'Понедельник':
        return 1;
      case 'Вторник':
        return 2;
      case 'Среда':
        return 3;
      case 'Четверг':
        return 4;
      case 'Пятница':
        return 5;
      case 'Суббота':
        return 6;
      case 'Воскресенье':
        return 7;
      default:
        return 1;
    }
  }

  static String getDayNameFromDate(String dateStr) {
    try {
      final date = parseDate(dateStr);
      return getRussianDayName(date);
    } catch (e) {
      return 'День';
    }
  }

  static bool isDateValid(DateTime date, String endDateStr) {
    try {
      final endDate = parseDate(endDateStr);
      return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
    } catch (e) {
      return true;
    }
  }

  static String getCurrentDateFormatted() {
    return formatDate(DateTime.now());
  }

  static bool isTodayDate(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && 
           now.month == date.month && 
           now.day == date.day;
  }
}