import 'package:jiffy/jiffy.dart';

import '../models/prayer.dart';
import '../models/prayers.dart';

Prayer getNextPrayer(DateTime time, PrayersModel today, bool summerTime, List prayerList) {
  DateTime fajr =
      DateTime(time.year, time.month, time.day, getHour(today.fajr), getMinute(today.fajr));
  DateTime shuruq =
      DateTime(time.year, time.month, time.day, getHour(today.shuruq), getMinute(today.shuruq));
  DateTime duhr =
      DateTime(time.year, time.month, time.day, getHour(today.duhr), getMinute(today.duhr));
  DateTime asr =
      DateTime(time.year, time.month, time.day, getHour(today.asr), getMinute(today.asr));
  DateTime maghrib =
      DateTime(time.year, time.month, time.day, getHour(today.maghrib), getMinute(today.maghrib));
  DateTime isha =
      DateTime(time.year, time.month, time.day, getHour(today.isha), getMinute(today.isha));
  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  if (time.isBefore(fajr)) return Prayer("Fajr", fajr);
  if (time.isBefore(shuruq)) return Prayer("Shuruq", shuruq);
  if (time.isBefore(duhr)) return Prayer("Duhr", duhr);
  if (time.isBefore(asr)) return Prayer("Asr", asr);
  if (time.isBefore(maghrib)) return Prayer("Maghrib", maghrib);
  if (time.isBefore(isha)) return Prayer("Isha", isha);

  //after Isha
  var dayInYear = Jiffy().dayOfYear;

  PrayersModel tomorrowPrayers =
      PrayersModel.fromJson(prayerList[dayInYear + 1]); //TODO: fix if last day of year.
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  DateTime fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
      getHour(tomorrowPrayers.fajr), getMinute(tomorrowPrayers.fajr));
  fajrTomorrow = summerTime ? fajrTomorrow.add(const Duration(hours: 1)) : fajrTomorrow;
  return Prayer("Fajr", fajrTomorrow);
}

Prayer getPrevPrayer(DateTime time, PrayersModel today, bool summerTime, List prayerList) {
  DateTime fajr =
      DateTime(time.year, time.month, time.day, getHour(today.fajr), getMinute(today.fajr));
  DateTime shuruq =
      DateTime(time.year, time.month, time.day, getHour(today.shuruq), getMinute(today.shuruq));
  DateTime duhr =
      DateTime(time.year, time.month, time.day, getHour(today.duhr), getMinute(today.duhr));
  DateTime asr =
      DateTime(time.year, time.month, time.day, getHour(today.asr), getMinute(today.asr));
  DateTime maghrib =
      DateTime(time.year, time.month, time.day, getHour(today.maghrib), getMinute(today.maghrib));
  DateTime isha =
      DateTime(time.year, time.month, time.day, getHour(today.isha), getMinute(today.isha));

  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  if (time.isAfter(isha)) return Prayer("Isha", isha);
  if (time.isAfter(maghrib)) return Prayer("Maghrib", maghrib);
  if (time.isAfter(asr)) return Prayer("Asr", asr);
  if (time.isAfter(duhr)) return Prayer("Duhr", duhr);
  if (time.isAfter(shuruq)) return Prayer("Shuruq", shuruq);
  if (time.isAfter(fajr)) return Prayer("Fajr", fajr);

  //before Fajr
  var dayInYear = Jiffy().dayOfYear;

  PrayersModel yesterdayPrayers =
      PrayersModel.fromJson(prayerList[dayInYear - 1]); //TODO: fix if first day of year.

  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
  DateTime ishaYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day,
      getHour(yesterdayPrayers.isha), getMinute(yesterdayPrayers.isha));
  ishaYesterday = summerTime ? ishaYesterday.add(const Duration(hours: 1)) : ishaYesterday;
  return Prayer("Isha", ishaYesterday);
}

int getHour(String time) {
  return int.parse(time.split(':')[0]);
}

int getMinute(String time) {
  return int.parse(time.split(':')[1]);
}
