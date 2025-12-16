import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateForDisplay(DateTime date) {
    return DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(date);
  }

  static DateTime removeTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  static DateTime getNextBirthday(DateTime birthDate) {
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return nextBirthday;
  }

  static int daysUntilNextBirthday(DateTime birthDate) {
    final nextBirthday = getNextBirthday(birthDate);
    final now = DateTime.now();
    return nextBirthday.difference(now).inDays;
  }
}