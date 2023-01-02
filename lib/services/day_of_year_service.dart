import 'package:jiffy/jiffy.dart';

int dayOfYear(DateTime day) {
  int dayOfYear = Jiffy(day).dayOfYear;
  dayOfYear--;

  var marchFirst = DateTime(day.year, DateTime.march, 1);
  if (!day.isBefore(marchFirst) && !isLeapYear(day.year)) {
    // Februaury 29.
    dayOfYear++;
  }

  return dayOfYear;
}

bool isLeapYear(int year) {
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } else {
    return false;
  }
}
